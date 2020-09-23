//
//  AWSService.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 23/09/2020.
//

import Foundation
import AWSTextract

class AWSService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OCRService {
    
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
        doc.bytes = image.resizedJpegData()

        let request = AWSTextractDetectDocumentTextRequest()!
        request.document = doc
        
        AWSTextract.default().detectDocumentText(request) { [unowned self] (response, err) in
            if let err = err {
                delegate?.documentDetectionFailed(err)
            } else {
                guard let blocks = response?.blocks else {
                    delegate?.documentDetected([])
                    return
                }
                var result: Set<OCRBlock> = []
                for block in blocks {
                    if block.isLineOrWord() == false {
                        continue
                    }
                    var b = OCRBlock(text: block.text ?? "Unknown text")
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
            delegate?.documentDetectionFailed(error(withMessage: "No image taken"))
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            guard let image = info[.originalImage] as? UIImage else {
                delegate?.documentDetectionFailed(error(withMessage: "No image taken"))
                return
            }
            
            delegate?.documentTaken(image)
            analyze(image: image)
        }
    }

}
