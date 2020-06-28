//
//  SYJTabBarController.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/6/28.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import UIKit

class SYJTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBarDarkModeAdapater()
    }
    
    
    private func tabBarDarkModeAdapater() -> Void {
        
        guard  let items = tabBar.items , items.count > 0 else {
            return
        }
        
        let tabBarItemSelectedColor: UIColor = UIColor.adapterDarkModeColor(dynamicColorName: "common_scheme_color", color: UIColor.yellow)
        tabBar.tintColor = tabBarItemSelectedColor
    }

}

extension SYJTabBarController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(#function)
        tabBarDarkModeAdapater()
    }
}
