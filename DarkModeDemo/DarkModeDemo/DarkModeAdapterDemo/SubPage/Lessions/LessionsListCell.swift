//
//  LessionsListCell.swift
//  DarkModeDemo
//
//  Created by ShenYj on 2020/7/15.
//  Copyright © 2020 ShenYj. All rights reserved.
//

import Foundation
import UIKit

class LessionsListCell: UITableViewCell {
    
    internal var hasLearned: Bool = false {
        didSet {
//            let img: String = hasLearned ? "checkmark.circle.fill" : "checkmark.circle"
//            hasLearnedImageView.image = UIImage(named: img)
            hasLearnedImageView.isHidden = !hasLearned
        }
    }
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var lessionNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var hasLearnedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
