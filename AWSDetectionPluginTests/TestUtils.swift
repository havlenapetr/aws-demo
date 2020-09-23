//
//  TestUtils.swift
//  AWSDetectionPluginTests
//
//  Created by Petr Havlena on 23/09/2020.
//

import UIKit
import AWSDetectionPlugin

extension OCRServiceDelegate {
    
    func testImage() -> UIImage {
        let path = Bundle(for: Self.self).path(forResource: "Employee-id-48-CRC", ofType: "jpg")
        return UIImage(contentsOfFile: path!)!
    }
    
}
