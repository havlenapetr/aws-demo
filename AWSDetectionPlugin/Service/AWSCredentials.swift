//
//  OCRCredentials.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit

class AWSCredentials {
    
    static let instance = AWSCredentials()
    
    private let credentials: NSDictionary
    
    lazy var accessKey: String = {
        return credentials["Access Key"] as? String ?? ""
    }()
    
    lazy var secretKey: String = {
        return credentials["Secret Key"] as? String ?? ""
    }()
    
    private init() {
        var path = Bundle.main.path(forResource: "Credentials", ofType: "plist")
        if (path == nil) {
            path = Bundle(for: Self.self).path(forResource: "Credentials", ofType: "plist")
        }
        if let path = path {
            credentials = NSDictionary(contentsOfFile: path)!
        } else {
            credentials = NSDictionary()
        }
    }
    
}
