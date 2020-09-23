//
//  OCRService.swift
//  AWSDemo
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit

public protocol OCRService: AnyObject {
    
    var delegate: OCRServiceDelegate? { get set }
    
    func setup()
    
    func takePhotoAndAnalyze() -> UIViewController
    
    func analyze(image: UIImage)
}

public class OCRServiceManager {
    
    public static let instance = OCRServiceManager()
    
    public enum OCRServiceType: Int {
        case AWS
        case Tesseract
    }
    
    private init() { }
    
    public func defaultService() -> OCRService {
        return service(byType: .AWS)
    }
    
    public func service(byType type: OCRServiceType) -> OCRService {
        switch type {
        case .AWS:
            return AWSService()
        case .Tesseract:
            return TesseractService()
        }
    }
}

extension OCRService {
 
    func takePhoto(withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = .camera
        imagePicker.modalPresentationStyle = .currentContext
        return imagePicker
    }
    
    func error(withMessage msg: String) -> Error {
        return NSError(domain: "OCRServiceException", code: 400, userInfo: [ NSLocalizedDescriptionKey : msg ])
    }
    
}
