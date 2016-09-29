//
//  LimitInputView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let StatusBarHeight:CGFloat = 20
private let TopBarHeight:CGFloat = 44
private let DateBarHeight:CGFloat = 30
private let TextFieldHeight:CGFloat = 180
private let MaxLengthOfRemark = 40

typealias completeRespond = (String)->()

extension LimitInputView:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placehoder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placehoder
            textView.textColor = UIColor.gray
        }
        textView.resignFirstResponder()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            if textView.text.length > MaxLengthOfRemark{
                let alertView = UIAlertView(title: "提示", message: "请不要超过40字", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles:
                    "确定")
                alertView.show()
            }
            else{
                self.back(self)
                if let complete = completeInput{
                    complete(textView.text)
                }
                textView.resignFirstResponder()
            }
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.length <= MaxLengthOfRemark{
            characterNum?.textColor = UIColor.black
        }
        else{
            characterNum?.textColor = UIColor.red
        }
        currentLengthOfRemark = textView.text.length
        characterNum?.text = "\(currentLengthOfRemark!)/40"
        
    }
}


class LimitInputView: UIView {

    weak var delegate:LimitInputVC?
    var initViewDate:String?
    var dateLabel:UILabel?
    var characterNum:UILabel?
    var currentLengthOfRemark:Int?
    var completeInput:completeRespond?
    
    var placehoder:String = "记录花销"
    var textInput:UITextView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let DateBarY = TopBarHeight + StatusBarHeight
        let TextFieldY = DateBarY + DateBarHeight
        //顶部栏
        setupTopBar(CGRect(x: 0, y: StatusBarHeight, width: frame.width, height: TopBarHeight))
        //日期
        setupDateBar(CGRect(x: 20, y: DateBarY, width: frame.width, height: DateBarHeight))
        //输入区域
        setupTextField(CGRect(x: 20, y: TextFieldY, width: frame.width - 40, height: TextFieldHeight))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dateLabel?.text = initViewDate
    }
    
    fileprivate func setupTopBar(_ frame:CGRect){
        //topbar
        let topBar = UIView(frame: frame)
        //返回按钮
        let topBarBack = UIButton(frame: CGRect(x: 20, y: 10, width: 22, height: 22))
        topBarBack.setImage(UIImage(named: "back_light"), for: UIControlState())
        topBarBack.addTarget(self, action: #selector(LimitInputView.back(_:)), for: .touchUpInside)
        //中间标题
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        title.text = "备注"
        title.center = CGPoint(x: frame.width / 2, y: 20)
        
        //分割线
        let topBarSepLine = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
        topBarSepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        
        //添加子view
        topBar.addSubview(title)
        topBar.addSubview(topBarBack)
        topBar.addSubview(topBarSepLine)
        self.addSubview(topBar)
    }
    fileprivate func setupDateBar(_ frame:CGRect){
        let dateLabel = UILabel(frame: frame)
        dateLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        dateLabel.font = UIFont(name: "Courier", size: 14)
        self.dateLabel = dateLabel
        self.addSubview(dateLabel)
    }
    fileprivate func setupTextField(_ frame:CGRect){
        let textInput = UITextView(frame: frame)
        textInput.font = UIFont(name: "Arial", size: 20)
        textInput.keyboardType = .default
        textInput.returnKeyType = .done
        textInput.text = placehoder
        textInput.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        textInput.delegate = self;
        self.textInput = textInput
        let characterNum = UILabel(frame: CGRect(x: 10, y: self.frame.height - 60, width: 80, height: 40))
        characterNum.text = "0/40"
        self.characterNum = characterNum
        self.addSubview(characterNum)
        self.addSubview(textInput)
    }
    
    //MARK: - action
    func back(_ sender:AnyObject){
        if delegate?.responds(to: #selector(LimitInputView.back(_:))) != nil{
            delegate?.clickBack()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
