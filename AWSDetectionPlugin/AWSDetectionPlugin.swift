//
//  AWSDetectionPlugin.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit

public typealias SuccessHandler = ((String?) -> Void)?
public typealias FailureHandler = ((Error?) -> Void)?

struct AnyEncodable: Encodable {

    let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

struct ResultModel {
    
    var success: SuccessHandler = nil
    var failure: FailureHandler = nil
    var data: [String: AnyEncodable] = [:]

}


///
/// Implementation of Quadient mobile SDK plugin interface
///
@objc open class AWSDetectionPlugin: NSObject, Plugin, OCRServiceDelegate {
    
    private let service = OCRServiceManager.instance.defaultService()
    
    public var messageTypeId: String?  = "findDocumentInImage"
    
    var result = ResultModel()
    
    public func pluginWillRegister() {
        service.delegate = self
        service.setup()
    }
    
    public func handleMessage(_ messageId: UInt, payload: [AnyHashable : Any], response: SuccessHandler, error: FailureHandler = nil) {
        if let controller = rootController() {
            var result = ResultModel()
            result.success = response
            result.failure = error
            self.result = result
            let imagePicker = service.takePhotoAndAnalyze()
            controller.present(imagePicker, animated: true)
        } else {
            error?(OCRServiceImpl.error(withMessage: "Unable to find root controller"))
        }
    }
    
    public func documentDetectionFailed(_ error: Error) {
        result.failure?(error)
    }
    
    public func documentDetected(_ data: [OCRBlock]) {
        do {
            result.data["result"] = AnyEncodable(String(data: try JSONEncoder().encode(data), encoding: .utf8))
            let json = String(data: try JSONEncoder().encode(result.data), encoding: .utf8)
            result.success?(json)
        } catch {
            result.failure?(error)
        }
    }
    
    public func documentTaken(_ image: UIImage) {
        if let imageData = image.base64EncodedJpeg() {
            result.data["image"] = AnyEncodable("data:image/jpeg;base64,\(imageData)")
        }
    }
    
    func rootController(_ base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return rootController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return rootController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return rootController(presented)
        }
        return base
    }

}

extension UIImage {
 
    func base64EncodedJpeg(_ quality: CGFloat = 1.0) -> String? {
        return self.jpegData(compressionQuality: quality)?.base64EncodedString(options: [])
    }
}
