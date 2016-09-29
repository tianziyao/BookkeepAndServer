//
//  AccountDisplayViewBase.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit
typealias presentVCResponder = ()->Void
class AccountCell: UITableViewCell {
    
    //MARK: - properties (internal)
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var iconTitle: UILabel!
    @IBOutlet weak var icon: UIButton!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var botmLine: UIView!
    @IBOutlet weak var dayIndicator: UIImageView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    var cellID:Int?
    var presentVCBlock:presentVCResponder?
    var deleteCell:presentVCResponder?
    
    //MARK: - private properties
    fileprivate var isHiddenSubview = false
    
    //MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - click action (internal)
    @IBAction func clickIcon(_ sender: AnyObject) {
        showSubView(!isHiddenSubview)
        showBtns(isHiddenSubview)
        isHiddenSubview = !isHiddenSubview
        UIView.animate(withDuration: 0.3, animations: {() in
            self.showSubView(!self.isHiddenSubview)
            self.showBtns(self.isHiddenSubview)
        })
    }
    
    @IBAction func clickEditBtn(_ sender: AnyObject) {

        if let block = presentVCBlock{
            block()
        }
    }
    
    @IBAction func clickDeleteBtn(_ sender: AnyObject) {

        if let block = deleteCell{
            block()
        }
    }
    
    //MARK: - prepare reuse (internal)
    override func prepareForReuse(){
        super.prepareForReuse()
        date.text = ""
        photoView.image = nil
        itemCost.text = ""
        iconTitle.text = ""
        remark.text = ""
        botmLine.isHidden = false
        topLine.isHidden = false
        dayIndicator.isHidden = true
        icon.setImage(nil, for: UIControlState())
        showSubView(true)
        showBtns(false)
        isHiddenSubview = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: - private
    fileprivate func showSubView(_ bool:Bool){
        let alpha:CGFloat = bool ? 1 : 0
        photoView.alpha = alpha
        iconTitle.alpha = alpha
        itemCost.alpha = alpha
        remark.alpha = alpha
        deleteBtn.center = bool ? self.icon.center : CGPoint(x: 60, y: self.icon.center.y)
        editBtn.center = bool ? self.icon.center : CGPoint(x: self.frame.width - 60, y: self.icon.center.y)
    }
    fileprivate func showBtns(_ bool:Bool){
        let alpha:CGFloat = bool ? 1 : 0
        deleteBtn.alpha = alpha
        editBtn.alpha = alpha
        deleteBtn.center = bool ? CGPoint(x: 60, y: self.icon.center.y) : self.icon.center
        editBtn.center = bool ? CGPoint(x: self.frame.width - 60, y: self.icon.center.y) :self.icon.center
    }
    

}
