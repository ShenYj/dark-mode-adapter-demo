//
//  InfoManager.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/7/16.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import Foundation

internal class InfoManager {
    
    // 全局访问单例
    static let shared: InfoManager = InfoManager()
    // 对外访问- token
    internal var accessToken: String? {
        get {
            return token
        }
    }
    // 对外访问- 控制倍速
    internal var offsetSeconds: Double {
        get {
            return Double(offsetSec)
        }
    }
    
    // 用户Token
    private var token: String?
    // 倍速 3/5/10
    private var offsetSec: Int = 5
    
    
}

// MARK: 对外接口
extension InfoManager {
    
    // 设置Token
    internal func updateToken(newToken: String?) {
        token = newToken
    }
    // 设置倍速
    internal func updatePlaySpeed(speed: Int) {
        offsetSec = speed
    }
    
}
