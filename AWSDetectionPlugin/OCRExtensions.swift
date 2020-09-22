//
//  OCRExtensions.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 22/09/2020.
//

import Foundation
import AWSTextract

extension AWSTextractBlock {
    
    func isLineOrWord() -> Bool {
        switch self.blockType {
        case .line, .word:
            return self.text != nil
        default:
            return false
        }
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

extension UIImage {
    
    func resizedJpegData(withPercentage percentage: CGFloat = 0.5) -> Data? {
        //let image = self.greyScaled() ?? self
        let image = self.resized(withPercentage: percentage)
        return image?.jpegData(compressionQuality: 1.0)
    }
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func greyScaled() -> UIImage? {
        let ciImage = CIImage(image: self)
        let parameters = [
            "inputContrast": NSNumber(value: 2),
            kCIInputSaturationKey: 0.0
        ]
        let grayscale = ciImage?.applyingFilter("CIColorControls", parameters: parameters)
        if let gray = grayscale{
            return UIImage(ciImage: gray)
        }
        return nil
    }
    
}

extension NSNumber {
    
    func cgfloat() -> CGFloat {
        return CGFloat(self.floatValue)
    }
    
}
