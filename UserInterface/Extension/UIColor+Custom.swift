//
//  UIColor+Custom.swift
//  Source
//
//  Created by Ian McDowell on 9/18/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

private extension Int {
    func duplicate4bits() -> Int {
        return (self << 4) + self
    }
}

public extension UIColor {

    /// Create non-autoreleased color with in the given hex string. Alpha will be set as 1 by default.
    /// - parameter hexString: The hex string, with or without the hash character.
    /// - returns: A color with the given hex string.
    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }

    fileprivate convenience init?(hex3: Int, alpha: Float) {
        self.init(red: CGFloat(((hex3 & 0xF00) >> 8).duplicate4bits()) / 255.0,
                  green: CGFloat(((hex3 & 0x0F0) >> 4).duplicate4bits()) / 255.0,
                  blue: CGFloat(((hex3 & 0x00F) >> 0).duplicate4bits()) / 255.0, alpha: CGFloat(alpha))
    }

    fileprivate convenience init?(hex6: Int, alpha: Float) {
        self.init(red: CGFloat((hex6 & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hex6 & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat((hex6 & 0x0000FF) >> 0) / 255.0, alpha: CGFloat(alpha))
    }

    /// Create non-autoreleased color with in the given hex string and alpha.
    /// - parameter hexString: The hex string, with or without the hash character.
    /// - parameter alpha: The alpha value, a floating value between 0 and 1.
    /// - returns: A color with the given hex string and alpha.
    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString

        // Check for hash and remove the hash
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }

        guard let hexVal = Int(hex, radix: 16) else {
            self.init()
            return nil
        }

        switch hex.count {
        case 3:
            self.init(hex3: hexVal, alpha: alpha)
        case 6:
            self.init(hex6: hexVal, alpha: alpha)
        default:
            // Note:
            // The swift 1.1 compiler is currently unable to destroy partially initialized classes in all cases,
            // so it disallows formation of a situation where it would have to.  We consider this a bug to be fixed
            // in future releases, not a feature. -- Apple Forum
            self.init()
            return nil
        }
    }

    /// Create non-autoreleased color with in the given hex value and alpha
    /// - parameter hex: The hex value. For example: 0xff8942 (no quotation).
    /// - parameter alpha: The alpha value, a floating value between 0 and 1.
    /// - returns: color with the given hex value and alpha
    public convenience init?(hex: Int, alpha: Float = 1.0) {
        if (0x000000 ... 0xFFFFFF) ~= hex {
            self.init(hex6: hex, alpha: alpha)
        } else {
            self.init()
            return nil
        }
    }

    /// Returns either black or white, whichever will show up better as text on the current
    /// color's background.
    ///
    /// - Returns: either black or white
    func colorBasedTextColor() -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let threshold: CGFloat = 105 / 255
        let bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114))

        let textcolor = (1 - bgDelta < threshold) ? UIColor.black : UIColor.white

        return textcolor
    }

    func lighted(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darkened(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0;
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)) {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}
