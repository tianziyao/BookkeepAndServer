//
//  TopBarView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class TopBarView: UIView {
    
    weak var delegate:ChooseItemVC?
    var topBarChangeTime:UIButton?
    var topBarAddRemark:UIButton?
    var topBarTakePhoto:UIButton?
    var topBarTakePhotoImage:UIButton?
    var topBarInitPhoto:UIImage?{
        get{
            return topBarTakePhotoImage?.imageView?.image
        }
        set(newValue){
            topBarTakePhotoImage?.setImage(newValue, for: UIControlState())
            topBarTakePhotoImage?.isHidden = false
            topBarTakePhoto?.isHidden = true
        }
    }
    //自定义初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        let TopBarWidth = self.frame.width
        let TopBarHeight = self.frame.height
        
        //返回
        let topBarBack = UIButton(frame: CGRect(x: 20, y: 10, width: 22, height: 22))
        topBarBack.setImage(UIImage(named: "back_light"), for: UIControlState())
        topBarBack.addTarget(self, action: #selector(TopBarView.back(_:)), for: .touchUpInside)
        //改时间
        let topBarChangeTime = createTopBarBtn(num: 1, title: "改时间", target: self, action: #selector(TopBarView.ChangeTimePress(_:)))
        self.topBarChangeTime = topBarChangeTime
        
        //写备注
        let topBarAddRemark = createTopBarBtn(num: 2, title: "写备注", target: self, action: #selector(TopBarView.AddRemarkPress(_:)))
        self.topBarAddRemark = topBarAddRemark
        
        //加照片
        let topBarTakePhoto = createTopBarBtn(num: 3, title: "加照片", target: self, action: #selector(TopBarView.TakePhotoPress(_:)))
        self.topBarTakePhoto = topBarTakePhoto
        
        let topBarTakePhotoImage = UIButton(frame: CGRect(x: self.frame.width/4 * 3 + 25 , y: 5, width: self.frame.height - 10, height: self.frame.height - 10 ))
        topBarTakePhotoImage.layer.cornerRadius = (self.frame.height - 10) / 2
        topBarTakePhotoImage.clipsToBounds = true
        topBarTakePhotoImage.isHidden = true
        topBarTakePhotoImage.addTarget(self, action: #selector(TopBarView.TakePhotoPress(_:)), for: .touchUpInside)
        self.topBarTakePhotoImage = topBarTakePhotoImage
        
        //分割线
        let topBarSepLine = UIView(frame: CGRect(x: 0, y: TopBarHeight - 0.5, width: TopBarWidth, height: 0.5))
        topBarSepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        
        //添加到topBar上
        self.addSubview(topBarBack)
        self.addSubview(topBarChangeTime)
        self.addSubview(topBarAddRemark)
        self.addSubview(topBarTakePhoto)
        self.addSubview(topBarTakePhotoImage)
        self.addSubview(topBarSepLine)
    }
    
    fileprivate func createTopBarBtn(num number:CGFloat, title:String, target:AnyObject, action:Selector) -> UIButton{
        
        let btn = UIButton(frame: CGRect(x: self.frame.width/4 * number, y: 0, width: self.frame.width/4, height: self.frame.height))
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.font = UIFont(name: "Courier New", size: 14)
        btn.setTitleColor(UIColor.black, for: UIControlState())
        btn.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), for: UIControlState.highlighted)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    func back(_ sender:AnyObject!){
        if delegate?.responds(to: #selector(ChooseItemVC.clickBack(_:))) != nil{
            delegate?.clickBack(sender)
        }
    }
    
    func ChangeTimePress(_ btn: UIButton?){
        if delegate?.responds(to: #selector(ChooseItemVC.clickTime)) != nil{
            delegate?.clickTime()
        }
    }
    func AddRemarkPress(_ btn: UIButton?){
        if delegate?.responds(to: #selector(ChooseItemVC.clickRemark)) != nil{
            delegate?.clickRemark()
        }
    }
    func TakePhotoPress(_ btn: UIButton?){
        if delegate?.responds(to: #selector(ChooseItemVC.clickRemark)) != nil{
            delegate?.clickPhoto()
        }
    }
    
}
