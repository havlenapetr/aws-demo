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
        service.analyze(image: testImage())
        wait(for: [expectation], timeout: 10.0)
        assertResult(result!)
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
