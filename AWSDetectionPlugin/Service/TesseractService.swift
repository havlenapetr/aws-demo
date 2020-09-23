//
//  TesseractService.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 23/09/2020.
//

import Foundation
import TesseractOCR

class TesseractService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OCRService {
    
    private lazy var tesseract: G8Tesseract = {
        print("Using Tesseract \(G8Tesseract.version())")
        return G8Tesseract(language: "eng")!
    }()
    
    weak var delegate: OCRServiceDelegate?
    
    func setup() {
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
    }
    
    public func takePhotoAndAnalyze() -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        return imagePicker
    }
    
    func analyze(image: UIImage) {
        DispatchQueue.global().async { [unowned self] in
            tesseract.image = image
            tesseract.recognize()
            guard let text = tesseract.recognizedText else {
                delegate?.documentDetected([])
                return
            }
            delegate?.documentDetected([OCRBlock(text: text)])
        }
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
