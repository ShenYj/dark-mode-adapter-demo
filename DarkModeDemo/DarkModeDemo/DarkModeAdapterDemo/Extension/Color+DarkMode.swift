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
    
    
    /// 适配 darkMode 获取颜色
    /// - Parameters:
    ///   - dynamicColorName: 如果适配darkMode, 传入自定义动态颜色的名称, 需 13.0+
    ///   - color: 备用颜色 /  (常规颜色) 非darkMode模式下的颜色   当不支持darkMode时, 或者为了防止动态颜色设置失败,
    /// - Returns: UIColor
    static func adapterDarkModeColor(dynamicColorName: String, color: UIColor?, darkMode: Bool = false) -> UIColor {
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
}
