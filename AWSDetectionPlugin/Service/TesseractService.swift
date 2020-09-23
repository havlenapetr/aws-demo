//
//  TesseractService.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 23/09/2020.
//

import Foundation
import TesseractOCR

class TesseractService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OCRService {

    weak var delegate: OCRServiceDelegate?
    
    func setup() {
    }
    
    public func takePhotoAndAnalyze() -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    func analyze(image: UIImage) {
    }
    
}
