//
//  ViewController.swift
//  AWSDemo
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit
import AWSDetectionPlugin

class ViewController: UIViewController, OCRServiceDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var analyzeButton: UIButton!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        service()?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let size = photoView.bounds.size
        photoView.image = welcomeTextImage(ofSize: size)
    }

    @IBAction func handleAnalyze(_ sender: Any) {
        if let imagePicker = service()?.takePhotoAndAnalyze() {
            present(imagePicker, animated: true)
        } else {
            presentErrorMessage("OCRService not available")
        }
    }
    
    func documentTaken(_ image: UIImage) {
        DispatchQueue.main.async { [unowned self] in
            loaderView.startAnimating()
            photoView.image = image
        }
    }
    
    func documentDetectionFailed(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            presentError(error)
            loaderView.stopAnimating()
        }
    }
    
    func documentDetected(_ data: [OCRBlock]) {
        DispatchQueue.main.async { [unowned self] in
            presentResult(data)
            loaderView.stopAnimating()
        }
    }
    
    private func welcomeTextImage(ofSize size: CGSize) -> UIImage {
        let msg = """
Hello, for analyze photo, please press button 'Analyze' below this text
                        |       |
                        |       |
                        |       |
                        |       |
                    ----         ----
                    \\               /
                     \\             /
                      \\           /
                       \\         /
                        \\       /
                         \\     /
                          \\   /
                           \\ /
"""
        let image = UIGraphicsImageRenderer(size: size).image {
            let backgroundColor = view.backgroundColor ?? UIColor.white
            backgroundColor.setFill()
            $0.fill(CGRect(origin: .zero, size: size))
        }
        return textToImage(drawText: msg, inImage: image, atPoint: CGPoint(x: 0, y: size.height / 3))
    }
    
    private func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 24)!,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    private func presentResult(_ result: [OCRBlock]) {
        let alert = UIAlertController(title: "Found blocks", message: result.debugDescription, preferredStyle: .alert)
        presentAlert(alert)
    }
    
    private func presentError(_ error: Error) {
        presentErrorMessage(error.localizedDescription)
    }
    
    private func presentErrorMessage(_ msg: String) {
        let alert = UIAlertController(title: "Error occured", message: msg, preferredStyle: .alert)
        presentAlert(alert)
    }
    
    private func presentAlert(_ alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true)
        }
    }
    
    private func service() -> OCRService? {
        return (UIApplication.shared.delegate as? AppDelegate)?.ocrService
    }
    
}

