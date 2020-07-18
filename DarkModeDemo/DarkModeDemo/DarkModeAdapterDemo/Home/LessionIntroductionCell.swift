//
//  LessionIntroductionCell.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/7/15.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class LessionIntroductionCell: UITableViewCell {
    
    var lessionInfo: [String: Any]? {
        didSet {
            
            if let lessionImg = lessionInfo?["img"],
                let url = URL(string: lessionImg as! String) {
                self.lessionImageView.af_setImage(withURL: url)
            }
            self.lessionNameLabel.text = lessionInfo?["course_name"] as? String
        }
    }
    
    
    @IBOutlet weak var lessionImageView: UIImageView!
    @IBOutlet weak var lessionNameLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
