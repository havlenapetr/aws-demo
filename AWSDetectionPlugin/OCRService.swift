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
        service().defaultServiceConfiguration = configuration
    }
    
    public func takePhotoAndAnalyze() -> UIViewController {
        assert(service().defaultServiceConfiguration != nil, "Call setup first")

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    public func analyze(image: UIImage) {
        assert(service().defaultServiceConfiguration != nil, "Call setup first")
        
        let doc = AWSTextractDocument()!
        doc.bytes = image.jpegData()

        let request = AWSTextractDetectDocumentTextRequest()!
        request.document = doc
        
        AWSTextract.default().detectDocumentText(request) { [unowned self] (response, err) in
            if let err = err {
                delegate?.documentDetectionFailed(err)
            } else {
                guard let blocks = response?.blocks else {
                    return
                }
                var result: Set<OCRBlock> = []
                for block in blocks {
                    if block.isLineOrWord() == false {
                        continue
                    }
                    var b = OCRBlock()
                    b.text = block.text ?? "Unknown text"
                    //if let box = block.geometry?.boundingBox {
                    //    b.rect = box.rect()
                    //}
                    result.insert(b)
                }
                delegate?.documentDetected(Array(result))
            }
        }
    }
    
    func service() -> AWSServiceManager {
        return AWSServiceManager.default()
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

}
