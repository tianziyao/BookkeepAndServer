//
//  ComputeBoardView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let CostBarTimeHeight: CGFloat = 20.0

private let costBarLeftIconMargin: CGFloat = 12
private let costBarLeftIconWidth:CGFloat = 48

private let costBarTitleMarginLeft: CGFloat = 12+48+12
private let costBarTitleWidth:CGFloat = 60

private let sepLineWidth: CGFloat = 1

typealias computedResultResponder = (Float)->Void

class ComputeBoardView: UIView {
    
    fileprivate let lastBtnTitle = ["收/支", "+", "OK"]
    fileprivate let btnTitle = [["1", "4", "7", "C"], ["2", "5", "8", "0"], ["3", "6", "9", "."]]
    
    fileprivate let CostBarHeight: CGFloat = 72.0
    
    //存放上一次的累加值
    fileprivate var result:Float = 0
    fileprivate var summand: Float = 0
    fileprivate var addend: Float = 0
    fileprivate var decimal:Float = 0
    fileprivate var numOfDecimal:Int = 0
    fileprivate var numOfInt = 0
    fileprivate var pressAdd = false
    fileprivate var pressEqual = false
    fileprivate var pressDot = false
    
    var costBarTitle:UILabel?
    var title:String{
        get{
            return costBarTitle?.text ?? ""
        }
        set(newValue){
            costBarTitle?.text = newValue
        }
    }
    var costBarMoney:UILabel!
    var money:String{
        get{
            return costBarMoney.text ?? ""
        }
        set(newValue){
            costBarMoney.text = newValue
        }
    }
    var costBarLeftIcon:UIImageView?
    var icon:UIImage? {
        get{
            return costBarLeftIcon?.image
        }
        set(newValue){
            costBarLeftIcon?.image = newValue
        }
    }
    var costBarTime:UILabel?
    var time:String{
        get{
            return costBarTime?.text ?? ""
        }
        set(newValue){
            costBarTime?.text = newValue
        }
    }
    
    var computedResult:computedResultResponder?{
        get{
            return computeLogic.computedMoney
        }
        set(newValue){
            computeLogic.computedMoney = newValue
        }
    }
    
    var pressOK:(()->Void)?{
        get{
            return computeLogic.pressOKClosure
        }
        set(newValue){
            computeLogic.pressOKClosure = newValue
        }
    }
    
    var pressIncomeAndCost:(()->Void)?{
        get{
            return computeLogic.pressIncomeAndCostClosure
        }
        set(newValue){
            computeLogic.pressIncomeAndCostClosure = newValue
        }
    }
    
    weak var delegate:ChooseItemVC?
    let computeLogic:ComputedBoardLogic
    
    
    //自定义初始化方法
    override init(frame: CGRect) {
        computeLogic = ComputedBoardLogic()
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        
    }
    
    func clickComputedBtn(_ btn:UIButton){
        let value = btn.currentTitle ?? ""
        computeLogic.Compute(value)
    }
    
    func shakeCostBarMoney(){
        let shakeAnimation = CAKeyframeAnimation(keyPath: "position.x")
        shakeAnimation.values = [0, 10, -10, 10, 0]        
        shakeAnimation.keyTimes = [0, NSNumber(value: 1/6.0), NSNumber(value: 3/6.0), NSNumber(value: 5/6.0), 1]
        shakeAnimation.duration = 0.4
        shakeAnimation.isAdditive = true
        costBarMoney.layer.add(shakeAnimation, forKey: "CostBarMoneyShake")
    }
    
    func setup(){
        let width = self.frame.width
        let ComputedBoardHeight = self.frame.height - CostBarHeight
        
        //生成消费金额栏
        setupCostBar(CGRect(x: 0, y: 0, width: width, height: CostBarHeight))
        //生成前三列button
        setUpThreeColunmBtn(CGRect(x: 0, y: CostBarHeight, width: width, height: ComputedBoardHeight))
        //生成最后一列button
        setUpLastColunmBtn(CGRect(x: 0, y: CostBarHeight, width: width, height: ComputedBoardHeight))
        //生成横竖分割线
        setUpSepLine(CGRect(x: 0, y: CostBarHeight, width: width, height: ComputedBoardHeight))
    }
    
    //分割线时间标签
    fileprivate func setupCostBarTime(_ frame: CGRect)->UILabel{
        
        //时间标签
        let costBarTime = UILabel(frame: CGRect(x: frame.width/3, y: -CostBarTimeHeight/2, width: frame.width/3, height: CostBarTimeHeight))
        costBarTime.textAlignment = .center
        costBarTime.backgroundColor = UIColor.white
        costBarTime.layer.cornerRadius = 10
        costBarTime.layer.borderWidth = sepLineWidth
        costBarTime.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7).cgColor
        costBarTime.font = UIFont(name: costBarTime.font.fontName, size: 14)
        costBarTime.textColor = UIColor.black
        self.costBarTime = costBarTime
        
        return costBarTime
    }
    //最左边图标
    fileprivate func setupCostBarLeftIcon(_ frame:CGRect)->UIImageView {
        let costBarLeftIcon = UIImageView(frame: CGRect(x: costBarLeftIconMargin, y: costBarLeftIconMargin, width: costBarLeftIconWidth, height: costBarLeftIconWidth))
        self.costBarLeftIcon = costBarLeftIcon
        return costBarLeftIcon
    }
    //标题
    fileprivate func setupCostBarTitle(_ frame: CGRect)->UILabel{
        let costBarTitle = UILabel(frame: CGRect(x: costBarTitleMarginLeft, y: 0, width: costBarTitleWidth, height: frame.height))
        costBarTitle.font = UIFont(name: "Arial", size: 20)
        self.costBarTitle = costBarTitle
        return costBarTitle
    }
    //右边金额显示
    fileprivate func setupCostBarMoney(_ frame: CGRect)->UILabel{
        let costBarMoney = UILabel(frame: CGRect(x: costBarTitleMarginLeft + costBarTitleWidth + 10, y: 0,
            width: frame.width - costBarTitleMarginLeft - costBarTitleWidth - 20 , height: frame.height))
        costBarMoney.textAlignment = .right
        costBarMoney.font = UIFont(name: "Arial", size: 35)
        self.costBarMoney = costBarMoney
        return costBarMoney
    }
    
    fileprivate func setupCostBar(_ frame:CGRect){
        
        let costBarBackground = UIView(frame: frame)
        //CostBar分割线
        let costBarSepLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: sepLineWidth))
        costBarSepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        //分割线时间标签
        costBarTime = setupCostBarTime(frame)
        //最左边图标
        costBarLeftIcon = setupCostBarLeftIcon(frame)
        //标题
        costBarTitle = setupCostBarTitle(frame)
        //右边金额显示
        costBarMoney = setupCostBarMoney(frame)
        
        costBarBackground.addSubview(costBarSepLine)
        costBarBackground.addSubview(costBarTime!)
        costBarBackground.addSubview(costBarLeftIcon!)
        costBarBackground.addSubview(costBarTitle!)
        costBarBackground.addSubview(costBarMoney!)
        self.addSubview(costBarBackground)
    }
    //生成前三列button
    fileprivate func setUpThreeColunmBtn(_ frame: CGRect){
        let btnWidth = frame.width/4
        let btnHeight = frame.height/4
        let btnY = frame.origin.y
        for col in 0 ..< btnTitle.count {
            for row in 0 ..< btnTitle[col].count {
                let btnFrame = CGRect(x: CGFloat(col) * btnWidth, y: CGFloat(row) * btnHeight + btnY, width: btnWidth, height: btnHeight)
                let btn = createBtn(btnFrame, title: btnTitle[col][row],normalImage: "btn_num_pressed",highlightedImage:"btn_num")
                self.addSubview(btn)
            }
        }
    }
    //生成最后一列button
    fileprivate func setUpLastColunmBtn(_ frame:CGRect){
        
        let btnWidth = frame.width/4
        let btnHeight = frame.height/4
        let btnY = frame.origin.y
        for row in 0 ..< lastBtnTitle.count{
            let btnFrame = CGRect(x: CGFloat(3) * btnWidth, y: CGFloat(row) * btnHeight + btnY , width: btnWidth, height: row == 2 ? btnHeight * 2: btnHeight)
            let btn = createBtn(btnFrame,title: lastBtnTitle[row],normalImage: "btn_num_pressed",highlightedImage: "btn_num")
            if row == 2 {
                computeLogic.okBtn = btn
                //                okBtn = btn
            }
            self.addSubview(btn)
        }
    }
    //生成横竖分割线
    fileprivate func setUpSepLine(_ frame: CGRect){
        let boardWidth = frame.width
        let boardHeight = frame.height
        
        let btnWidth = boardWidth/4
        let btnHeight = boardHeight/4
        let btnY = frame.origin.y
        
        //行分割线
        for row in 0 ..< 3{
            let rowLine = UIView(frame: CGRect(x: 0, y: CGFloat(row + 1) * btnHeight + btnY, width: row == 2 ? boardWidth - btnWidth : boardWidth, height: sepLineWidth))
            rowLine.backgroundColor = UIColor.white
            self.addSubview(rowLine)
        }
        //竖分割线
        for col in 0 ..< 3{
            let colLine = UIView(frame: CGRect(x: CGFloat(col + 1) * btnWidth, y: btnY, width: sepLineWidth, height: boardHeight))
            colLine.backgroundColor = UIColor.white
            self.addSubview(colLine)
        }
    }
    
    fileprivate func createBtn(_ frame: CGRect, title:String, normalImage:String, highlightedImage: String) -> UIButton{
        let btn = UIButton(frame: frame)
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = UIFont(name: "Arial", size: 25)
        btn.setTitleColor(UIColor.black, for: UIControlState())
        btn.setBackgroundImage(UIImage(named: normalImage), for: UIControlState())
        btn.setBackgroundImage(UIImage(named: highlightedImage), for: .highlighted)
        btn.addTarget(self, action: #selector(ComputeBoardView.clickComputedBtn(_:)), for: .touchUpInside)
        return btn
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

