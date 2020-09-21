//
//  OCRServiceDelegate.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit

public protocol OCRServiceDelegate: AnyObject {
        
    func documentDetectionFailed(_ error: Error)
    
    func documentDetected(_ data: [OCRBlock])
    
    func documentTaken(_ image: UIImage)
    
}
