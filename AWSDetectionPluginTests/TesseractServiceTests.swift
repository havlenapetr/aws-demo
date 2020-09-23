//
//  AWSDetectionPluginTests.swift
//  AWSDetectionPluginTests
//
//  Created by Petr Havlena on 23/09/2020.
//

import XCTest
import AWSDetectionPlugin

class TesseractServiceTests: XCTestCase, OCRServiceDelegate {
    
    var expectation: XCTestExpectation!
    var result: [OCRBlock]?
    
    lazy var service: OCRService = {
        let service = OCRServiceManager.instance.service(byType: .Tesseract)
        service.delegate = self
        service.setup()
        return service
    }()

    func testAnalyzeIdCard() throws {
        expectation = XCTestExpectation()
        let path = Bundle(for: Self.self).path(forResource: "Employee-id-48-CRC", ofType: "jpg")
        let image = UIImage(contentsOfFile: path!)
        
        service.analyze(image: image!)
        wait(for: [expectation], timeout: 10.0)
        
        let labels = result?.map{ $0.label() }
        XCTAssertNotNil(labels?.first(where: { $0 == "City, Fake Street, Zip Code"}))
        XCTAssertNotNil(labels?.first(where: { $0 == "Fake Location" }))
        XCTAssertNotNil(labels?.first(where: { $0 == "987456321"}))
        XCTAssertNotNil(labels?.first(where: { $0 == "Employee Number" }))
        //XCTAssertNotNil(labels?.first(where: { $0 == "COMPANY NAME" }))
    }

    func documentDetectionFailed(_ error: Error) {
        expectation.fulfill()
    }
    
    func documentDetected(_ data: [OCRBlock]) {
        result = data
        expectation.fulfill()
    }
    
    func documentTaken(_ image: UIImage) {
    }
    
}
