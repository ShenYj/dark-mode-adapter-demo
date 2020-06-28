//
//  Color+DarkMode.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/6/28.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /// 获取十六进制字符串值
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    
    /// 依据十六进制字符串设定颜色
    /// - Parameter hexString: 十六进制色值 格式: #FFFFFF
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
         
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /// 适配 darkMode 获取颜色
    /// - Parameters:
    ///   - dynamicColorName: 如果适配darkMode, 传入自定义动态颜色的名称, 需 13.0+
    ///   - color: 备用颜色 /  (常规颜色) 非darkMode模式下的颜色   当不支持darkMode时, 或者为了防止动态颜色设置失败,
    /// - Returns: UIColor
    internal static func adapterDarkModeColor(dynamicColorName: String, color: UIColor?) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                
                guard let dynamicColor = UIColor(named: dynamicColorName) else {
                    guard let c = color else {
                        return UIColor.white
                    }
                    return c
                }
                return dynamicColor
            }
        }
        guard let c = color else {
            return UIColor.white
        }
        return c
    }
    
    internal static func lightModeSchemeColor() -> UIColor {
        return UIColor(hexString: "#6A5ACD")
    }
    
    
    /// 依据一直RGBA 设置颜色
    /// - Parameters:
    ///   - red: r
    ///   - green: g
    ///   - blue: b
    ///   - alpha: a
    /// - Returns: color
    internal static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
}
