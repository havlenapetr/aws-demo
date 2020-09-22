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
    
    func jpegData(forResolution resolution: (CGFloat, CGFloat) = (1024, 720)) -> Data? {
        //let image = self.greyScaled() ?? self
        let quality = UIImage.compressQuality(ofImage: self, forResolution: resolution)
        return self.jpegData(compressionQuality: quality)
    }
    
    private static func compressQuality(ofImage image: UIImage, forResolution resolution: (CGFloat, CGFloat)) -> CGFloat {
        let width = max(resolution.0, resolution.1) / max(image.size.height, image.size.width)
        let height = min(resolution.0, resolution.1) / min(image.size.height, image.size.width)
        return min(width, height)
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
