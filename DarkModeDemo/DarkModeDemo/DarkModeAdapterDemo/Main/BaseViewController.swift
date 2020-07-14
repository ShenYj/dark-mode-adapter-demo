//
//  SYJBaseViewController.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/6/28.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemFill
        } else {
            view.backgroundColor = UIColor.white
        }
        setupUI()
    }
}

extension BaseViewController {
    func setupUI() -> Void {
        
    }
}
