

import Foundation
import UIKit

extension UIColor {
    
    static var munectingBlue: UIColor {
        let red = CGFloat((432066 >> 16) & 0xFF) / 255.0
        let green = CGFloat((432066 >> 8) & 0xFF) / 255.0
        let blue = CGFloat(432066 & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static var munectingPurple: UIColor {
        let hexColor: UInt32 = 0x432066
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

       return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static var munectingGreen:UIColor {
        let hexColor: UInt32 = 0x00F4AA
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static var munectingCUColor: UIColor{
        let hexColor: UInt32 = 0xA47C6D
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static var munectingPink: UIColor{
        let hexColor: UInt32 = 0xBF6F6F
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
    
    static var munectingDeepPurple: UIColor{
        let hexColor: UInt32 = 0x2A0940
        let red = CGFloat((hexColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexColor & 0x0000FF) / 255.0

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
    
    static var navWhiteColor: UIColor{
        return UIColor(red: 0.7960000038146973, green: 0.8270000219345093, blue: 0.8629999756813049, alpha: 1.0)
    }
    
    static var stockInsightBlue: UIColor{
        return UIColor(red: 0.149, green: 0.098, blue: 1.0, alpha: 1.0)
    }
    
    
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    
    
}

