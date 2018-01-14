//
//  UIImage+Custom.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import ObjectiveC
import UIKit

private var avgAssociationKey: UInt8 = 0

public extension UIImage {
    
    public static var close: UIImage {
        return UIImage.init(named: "Close", in: Bundle.init(identifier: "net.ianmcdowell.UserInterface"), compatibleWith: nil)!
    }

    /// Scales the image to the given CGSize
    ///
    /// - Parameter size: the destination size for the image
    /// - Returns: a scaled image
    public func scaled(toSize size: CGSize) -> UIImage {
        if self.size == size {
            return self
        }

        #if DEBUG
        if size.width > self.size.width || size.height > self.size.height {
            assertionFailure("Image is being scaled up from its size.")
        }
        #endif
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        assert(newImage?.size == size, "Image size scaling was incorrect. Expected size: \(size), actual: \(newImage!.size)")
        return newImage!.withRenderingMode(self.renderingMode)
    }

    /// Scales the image proportionally to the given width
    ///
    /// - Parameter size: the destination width for the image
    /// - Returns: a scaled image
    public func scaled(toWidth width: CGFloat) -> UIImage {
        return self.scaled(
            toSize: CGSize(
                width: width,
                height: round(self.size.height * (width / self.size.width))
            )
        )
    }

    /// Scales the image proportionally to the given height
    ///
    /// - Parameter size: the destination width for the image
    /// - Returns: a scaled image
    public func scaled(toHeight height: CGFloat) -> UIImage {
        return self.scaled(
            toSize: CGSize(
                width: round(self.size.width * (height / self.size.height)),
                height: height
            )
        )
    }

    private var cachedAverage: UIColor? {
        get {
            return objc_getAssociatedObject(self, &avgAssociationKey) as? UIColor
        }
        set(newValue) {
            objc_setAssociatedObject(self, &avgAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Calculates the average UIColor from the image. Uses the CIAreaAverage CIFilter.
    ///
    /// - Returns: a color representing the average of all colors in the image.
    public func averageColor() -> UIColor {
        if let cached = self.cachedAverage {
            return cached
        }

        let ciImage = UIKit.CIImage(image: self)!
        let ciContext = CIContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let totalBytes = 4 // Bytes requires to hold 1x1 image returned from Area Average filter
        let bitmap = UnsafeMutableRawPointer.allocate(bytes: 4, alignedTo: MemoryLayout<UInt8>.size)

        let averageImageFilter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: ciImage])!

        let averageImage = averageImageFilter.outputImage!

        ciContext.render(averageImage,
                         toBitmap: bitmap,
                         rowBytes: totalBytes,
                         bounds: averageImage.extent,
                         format: kCIFormatRGBA8,
                         colorSpace: colorSpace)

        let rgba = UnsafeBufferPointer(start: bitmap.assumingMemoryBound(to: UInt8.self), count: totalBytes)

        let red = CGFloat(rgba[0]) / 255
        let green = CGFloat(rgba[1]) / 255
        let blue = CGFloat(rgba[2]) / 255

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)

        self.cachedAverage = color

        bitmap.deallocate(bytes: 4, alignedTo: MemoryLayout<UInt8>.size)
        return color
    }
}
