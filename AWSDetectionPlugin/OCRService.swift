//
//  OCRService.swift
//  AWSDemo
//
//  Created by Petr Havlena on 21/09/2020.
//

import Foundation

import AWSTextract

public protocol OCRService: AnyObject {
    
    var delegate: OCRServiceDelegate? { get set }
    
    func setup()
    
    func takePhotoAndAnalyze() -> UIViewController
    
    func analyze(image: UIImage)
}

public class OCRServiceManager {
    
    public static let instance = OCRServiceManager()
    
    public func defaultService() -> OCRService {
        let credentials = OCRCredentials.instance
        return OCRServiceImpl(accessKey: credentials.accessKey, secretKey: credentials.secretKey)
    }
}

class OCRServiceImpl: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OCRService {
    
    private let credentials: AWSStaticCredentialsProvider
    
    weak var delegate: OCRServiceDelegate?
    
    init(accessKey: String, secretKey: String) {
        credentials = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
    }
    
    public func setup() {
        let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider: credentials)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    public func takePhotoAndAnalyze() -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    public func analyze(image: UIImage) {
        let doc = AWSTextractDocument()!
        doc.bytes = compressedImage(image)

        let request = AWSTextractDetectDocumentTextRequest()!
        request.document = doc
        
        AWSTextract.default().detectDocumentText(request) { [unowned self] (response, err) in
            if let err = err {
                print("Unable to analyze image: '\(err)'")
                delegate?.documentDetectionFailed(err)
            } else {
                guard let blocks = response?.blocks else {
                    return
                }
                var result: Set<OCRBlock> = []
                for block in blocks {
                    guard let text = block.text else {
                        // don't process invalid detected texts
                        continue
                    }
                    var b = OCRBlock()
                    b.text = text
                    //if let box = block.geometry?.boundingBox {
                    //    b.rect = box.rect()
                    //}
                    result.insert(b)
                }
                delegate?.documentDetected(Array(result))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [unowned self] in
            delegate?.documentDetectionFailed(OCRServiceImpl.error(withMessage: "No image taken"))
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            guard let image = info[.originalImage] as? UIImage else {
                delegate?.documentDetectionFailed(OCRServiceImpl.error(withMessage: "No image taken"))
                return
            }
            
            delegate?.documentTaken(image)
            analyze(image: image)
        }
    }
    
    static func error(withMessage msg: String) -> Error {
        return NSError(domain: "OCRServiceException", code: 400, userInfo: [ NSLocalizedDescriptionKey : msg ])
    }
    
    private func compressedImage(_ image: UIImage) -> Data? {
        //let image = greyScaledImage(image) ?? image
        let quality = compressQuality(ofImage: image, forResolution: (640, 425))
        return image.jpegData(compressionQuality: quality)
    }
    
    private func compressQuality(ofImage image: UIImage, forResolution resolution: (CGFloat, CGFloat)) -> CGFloat {
        let width = max(resolution.0, resolution.1) / max(image.size.height, image.size.width)
        let height = min(resolution.0, resolution.1) / min(image.size.height, image.size.width)
        return min(width, height)
    }
    
    private func greyScaledImage(_ image: UIImage) -> UIImage? {
        let ciImage = CIImage(image: image)
        let grayscale = ciImage?.applyingFilter("CIColorControls", parameters: [ kCIInputSaturationKey: 0.0 ])
        if let gray = grayscale{
            return UIImage(ciImage: gray)
        }
        return nil
    }
}

extension AWSTextractBoundingBox {
    
    func rect() -> CGRect {
        return CGRect(x: self.left?.cgfloat() ?? 0,
                      y: self.top?.cgfloat() ?? 0,
                      width: self.width?.cgfloat() ?? 0,
                      height: self.height?.cgfloat() ?? 0)
    }
    
}

extension NSNumber {
    
    func cgfloat() -> CGFloat {
        return CGFloat(self.floatValue)
    }
    
}
