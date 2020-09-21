//
//  AppDelegate.swift
//  AWSDemo
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit
import AWSDetectionPlugin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let ocrService = OCRServiceManager.instance.defaultService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ocrService.setup()
        return true
    }

}

