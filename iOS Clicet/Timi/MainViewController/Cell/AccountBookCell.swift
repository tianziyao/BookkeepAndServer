//
//  AccountDisplayViewBase.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

enum AccountCellPressState:CGFloat{
    case longPress = 0.6
    case highlighted = 0.3
    case normal = 0.0
}

class AccountBookCell: UICollectionViewCell {

    @IBOutlet weak var highlightedView: UIView!
    @IBOutlet weak var selectedFlag: UIImageView!
    @IBOutlet weak var accountCounts: UILabel!
    @IBOutlet weak var accountTitle: UILabel!
    @IBOutlet weak var accountBackImage: UIImageView!
    
    var highlightedViewAlpha:CGFloat{
        get{
            return highlightedView.alpha
        }
        set(newValue){
            highlightedView.alpha = newValue
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //重用前做一些必要的初始化
    override func prepareForReuse() {
        selectedFlag.alpha = 0
        accountCounts.text = ""
        accountTitle.text = ""
        accountBackImage.image = nil
        highlightedViewAlpha = 0
    }

}
