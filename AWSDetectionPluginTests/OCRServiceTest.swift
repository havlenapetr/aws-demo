//
//  TestUtils.swift
//  AWSDetectionPluginTests
//
//  Created by Petr Havlena on 23/09/2020.
//

import UIKit
import XCTest
import AWSDetectionPlugin

extension OCRServiceDelegate {
    
    func testImage() -> UIImage {
        let path = Bundle(for: Self.self).path(forResource: "Employee-id-48-CRC", ofType: "jpg")
        return UIImage(contentsOfFile: path!)!
    }
    
    func assertResult(_ result: [OCRBlock]) {
        let labels = result.map{ $0.label() }
        //XCTAssertNotNil(labels.first(where: { $0 == "City, Fake Street, Zip Code"}))
        XCTAssertNotNil(labels.first(where: { $0 == "Fake Location" }))
        XCTAssertNotNil(labels.first(where: { $0 == "987456321"}))
        XCTAssertNotNil(labels.first(where: { $0 == "Employee Number" }))
        //XCTAssertNotNil(labels?.first(where: { $0 == "COMPANY NAME" }))
    }
    
}
