//
//  DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Kingfisher
import SwiftDate
import TTTAttributedLabel
import UIKit

fileprivate let locale = Locale(identifier: "en")
fileprivate let region = Region(tz: .currentAutoUpdating,
                                cal: .currentAutoUpdating,
                                loc: .english)

extension Date {
    func naturalString(withPreposition: Bool = false) -> String {
        let date = Date()
        let timeInterval = date.timeIntervalSince(self)

        if timeInterval.in(.month)! >= 1 {
            let abosulteDate = string(dateStyle: .medium, timeStyle: .none, in: region)
            return withPreposition ? "on " + abosulteDate : abosulteDate
        } else {
            let suffix = timeInterval > 0 ? "ago" : "later"
            var options = ComponentsFormatterOptions(allowedUnits: [.second, .minute, .hour, .day], style: .full, zero: .dropAll)
            options.maxUnitCount = 1
            options.locale = locale
            return try! "\(timeInterval.string(options: options)) \(suffix)"
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xFF, green: (netHex >> 8) & 0xFF, blue: netHex & 0xFF)
    }
}

extension UIImage {
    class var defaultAvatar: UIImage {
        return UIImage(named: "default-avatar")!.kf.image(withRoundRadius: 6, fit: CGSize(width: 60, height: 60))
    }

    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

extension UIImageView {
    func setAvatar(with avatarURL: URL?) {
        let processor = RoundCornerImageProcessor(cornerRadius: 12, targetSize: CGSize(width: 120, height: 120))
        kf.setImage(with: avatarURL, placeholder: UIImage.defaultAvatar, options: [.processor(processor)])
    }
}

extension UIView {
    func addSubviews(_ subviews: [UIView], usingAutoLayout: Bool = true) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = !usingAutoLayout
            addSubview(view)
        }
    }
}

extension TTTAttributedLabel {
    func addLink(_ url: URL, toText text: String) {
        let regexString = NSString(format: "(^|\\s)%1$@(\\s|$)", text) as String
        let range = (self.text! as NSString).range(of: regexString, options: .regularExpression)
        addLink(to: url, with: range)
    }
}

extension Data {
    static func dataFromGHBase64String(_ base64String: String) -> Data? {
        let encodedString = base64String.replacingOccurrences(of: "\n", with: "")
        return Data(base64Encoded: encodedString, options: NSData.Base64DecodingOptions(rawValue: 0))
    }
}

extension String {
    static func stringFromGHBase64String(_ base64String: String) -> String? {
        let data = Data.dataFromGHBase64String(base64String)
        return String(data: data!, encoding: String.Encoding.utf8)
    }

    var pathExtension: String {
        return (self as NSString).pathExtension
    }

    func removePrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(self[prefix.endIndex ..< self.endIndex])
        }

        return self
    }

    func substring(to _: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: 7)])
    }
}
