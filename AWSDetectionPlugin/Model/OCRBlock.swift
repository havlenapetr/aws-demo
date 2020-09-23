//
//  OCRBlock.swift
//  AWSDetectionPlugin
//
//  Created by Petr Havlena on 21/09/2020.
//

import UIKit

public struct OCRBlock: Encodable, Hashable {
    
    var text = ""
    var rect = CGRect()
    
    enum CodingKeys: String, CodingKey {
        case text = "label"
        case x = "left"
        case y = "top"
        case w = "width"
        case h = "height"
    }
    
    init() {
    }
    
    init(text: String) {
        self.text = text
    }
    
    public func label() -> String {
        return self.text
    }
    
    public static func == (lhs: OCRBlock, rhs: OCRBlock) -> Bool {
        return lhs.text == rhs.text && lhs.rect == rhs.rect
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        if rect.isEmpty == false {
            try container.encode(rect.origin.x, forKey: .x)
            try container.encode(rect.origin.y, forKey: .y)
            try container.encode(rect.size.width, forKey: .w)
            try container.encode(rect.size.height, forKey: .h)
        }
    }
    
    func intersects(with block: OCRBlock) -> Bool {
        return rect.intersects(block.rect)
    }
    
    var description: String {
        return "OCRBlock(\(text), \(rect))"
    }
}
