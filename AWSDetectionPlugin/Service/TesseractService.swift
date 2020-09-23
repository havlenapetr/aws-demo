//
//  TesseractService.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 23/09/2020.
//

import Foundation
import SwiftyTesseract

class TesseractService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OCRService {
    
    private lazy var tesseract: SwiftyTesseract = {
        return SwiftyTesseract(languages: [.english, .czech], bundle: Bundle(for: Self.self))
    }()
    
    weak var delegate: OCRServiceDelegate?
    
    func setup() {
        print("Using Tesseract v\(tesseract.version ?? "?.?.?")")
    }
    
    public func takePhotoAndAnalyze() -> UIViewController {
        return takePhotoAndAnalyze(withDelegate: self)
    }
    
    func analyze(image: UIImage) {
        DispatchQueue.global().async { [unowned self] in
            do {
                var result: Set<OCRBlock> = []
                let text = try tesseract.performOCR(on: image).get()
                text.enumerateLines { (line, _) in
                    result.insert(OCRBlock(text: line))
                }
                delegate?.documentDetected(Array(result))
            } catch {
                delegate?.documentDetectionFailed(error)
            }
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
