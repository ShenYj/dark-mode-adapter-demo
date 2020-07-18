//
//  SYJSettingViewController.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/6/28.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import UIKit

@IBDesignable
class SettingViewController: UIViewController {
    
    @IBOutlet weak var setPlaySpeedSegment: UISegmentedControl!
    @IBOutlet weak var inputTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "设置"
        setPlaySpeedSegment.selectedSegmentIndex = 1
        inputTextView.layer.cornerRadius = 5
        inputTextView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    
    func test() {
        let alert = UIAlertController(title: "登录?", message: nil, preferredStyle: .alert)
        let login = UIAlertAction(title: "登录", style: .default) { (action) in
            
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(login)
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: 事件
extension SettingViewController {
    @IBAction func setPlaySpeed(_ sender: Any) {
        
        var defaultSpeed: Int = Int(InfoManager.shared.offsetSeconds)
        switch setPlaySpeedSegment.selectedSegmentIndex {
        case 0:
            defaultSpeed = 3
        case 1:
            defaultSpeed = 5
        case 2:
            defaultSpeed = 10
        default:
            print("default")
        }
        InfoManager.shared.updatePlaySpeed(speed: defaultSpeed)
    }
}
