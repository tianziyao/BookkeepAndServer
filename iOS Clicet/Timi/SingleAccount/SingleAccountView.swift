//
//  SingleAccountView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let HeadBarHeight:CGFloat = 155

private let BtnWidth:CGFloat = 35
private let BtnMargin:CGFloat = 10
private let StatusBarHeight:CGFloat = 20

private let MidBtnWidth:CGFloat = 60
private let MidBtnHeight:CGFloat = 20
private let MidBtnMarginTop:CGFloat = 20


private let LabelMargin:CGFloat = 15
private let LabelWidth:CGFloat = 145
private let LabelHeight:CGFloat = 30


class SingleAccountView: UIView {
    
    //MARK: - public properties
    weak var delegate:SingleAccountVC!
    
    var incomeText:String?{
        get {
            return totalIncomeNum.text
        }
        set(newValue){
            totalIncomeNum.text = newValue
        }
    }
    
    var costText:String?{
        get {
            return totalCostNum.text
        }
        set(newValue){
            totalCostNum.text = newValue
        }
    }
    
    var midBtnTitle:String?{
        get {
            return midBtn.titleLabel?.text
        }
        set(newValue){
            midBtn.setTitle(newValue, for: UIControlState())
        }
    }
    
    //MARK: - private properties
    fileprivate var tableView:UITableView!
    fileprivate var totalIncomeNum:UILabel!
    fileprivate var totalCostNum:UILabel!
    fileprivate var midBtn:UIButton!
    
    //MARK: - init methods (internal)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame:CGRect, delegate:SingleAccountVC!){
        self.init(frame: frame)
        //tableView的数据源和代理应该在其初始化之前就建立好
        self.delegate = delegate
        setup(frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -  operation (internal)
    func reloadViews(){
        tableView?.reloadData()
    }
    
    //MARK: - click action methods (internal)
    func clickManageBtn(_ sender:AnyObject!){
        if delegate.responds(to: #selector(SingleAccountView.clickManageBtn(_:))) != false{
            delegate.clickManageBtn(sender)
        }
    }
    func clickMidAddBtn(_ sender:AnyObject!){
        if delegate.responds(to: #selector(SingleAccountView.clickMidAddBtn(_:))) != false{
            delegate.clickMidAddBtn(sender)
        }
    }
    
    //MARK: - setup views methods (private)
    fileprivate func setup(_ frame:CGRect){
        
        
        //头部view
        setupHeadBar(CGRect(x: 0, y: 0, width: frame.width, height: HeadBarHeight))
        //中间add按钮
        setupMidAddBtn(frame)
        //收入支出栏
        setupIncomeCostBar(frame)
        //流水账
        let DayAccountsY = HeadBarHeight + LabelMargin * 2  + LabelHeight * 2
        setupDayAccounts(CGRect(x: 0, y: DayAccountsY, width: frame.width, height: frame.height - DayAccountsY))
    }
    
    //头部view
    fileprivate func setupHeadBar(_ frame:CGRect){
        
        let HeadBarWidth:CGFloat = frame.width
        
        let headBar = UIImageView(frame: frame)
        headBar.image = UIImage(named: "background1")
        headBar.isUserInteractionEnabled = true
        
        let manageBtn = UIButton(frame: CGRect(x: BtnMargin, y: BtnMargin + StatusBarHeight, width: BtnWidth, height: BtnWidth))
        manageBtn.setImage(UIImage(named: "btn_menu"), for: UIControlState())
        manageBtn.addTarget(self, action: #selector(SingleAccountVC.clickManageBtn(_:)), for: .touchUpInside)
        
        let midBtn = UIButton(frame: CGRect(x: 0, y: 0, width: MidBtnWidth, height: MidBtnHeight))
        midBtn.center = CGPoint(x: HeadBarWidth/2, y: MidBtnMarginTop + StatusBarHeight)
        midBtn.setTitle("日常账本", for: UIControlState())
        midBtn.titleLabel?.font = UIFont(name: "Courier", size: 12)
        midBtn.layer.cornerRadius = 10
        midBtn.layer.borderColor = UIColor.white.cgColor
        midBtn.layer.borderWidth = 1
        self.midBtn = midBtn
        
        let takePhotoBtn = UIButton(frame: CGRect(x: HeadBarWidth - BtnMargin - BtnWidth, y: BtnMargin + StatusBarHeight, width: BtnWidth, height: BtnWidth))
        takePhotoBtn.setImage(UIImage(named: "btn_camera"), for: UIControlState())
        
        headBar.addSubview(manageBtn)
        headBar.addSubview(midBtn)
        headBar.addSubview(takePhotoBtn)
        
        self.addSubview(headBar)
    }
    //中间add按钮
    fileprivate func setupMidAddBtn(_ frame:CGRect){
        let MidAddBtnWidth:CGFloat = 90
        let midAddBtn = UIButton(frame: CGRect(x: 0, y: 0, width: MidAddBtnWidth, height: MidAddBtnWidth))
        midAddBtn.center = CGPoint(x: frame.width/2, y: HeadBarHeight)
        midAddBtn.setImage(UIImage(named: "circle_btn"), for: UIControlState())
        midAddBtn.backgroundColor = UIColor.white
        midAddBtn.layer.cornerRadius = 45
        midAddBtn.addTarget(self, action: #selector(SingleAccountVC.clickMidAddBtn(_:)), for: .touchUpInside)
        
        self.addSubview(midAddBtn)
    }
    //收入支出栏
    fileprivate func setupIncomeCostBar(_ frame:CGRect){
        
        let income = UILabel(frame: CGRect(x: LabelMargin, y: HeadBarHeight + LabelMargin, width: LabelWidth, height: LabelHeight))
        income.text = "收入"
        
        let CostX = frame.width - LabelWidth - LabelMargin
        let cost = UILabel(frame: CGRect(x: CostX, y: HeadBarHeight + LabelMargin, width: LabelWidth, height: LabelHeight))
        cost.textAlignment = .right
        cost.text = "支出"
        
        let IncomeNumY = HeadBarHeight + LabelMargin + LabelHeight
        let incomeNum = UILabel(frame: CGRect(x: LabelMargin, y: IncomeNumY, width: LabelWidth, height: LabelHeight))
        incomeNum.text = "0.00"
        self.totalIncomeNum = incomeNum
        
        let costNum = UILabel(frame: CGRect(x: CostX, y: IncomeNumY, width: LabelWidth, height: LabelHeight))
        costNum.textAlignment = .right
        costNum.text = "0.00"
        self.totalCostNum = costNum
        
        self.addSubview(income)
        self.addSubview(cost)
        self.addSubview(incomeNum)
        self.addSubview(costNum)
    }
    //流水账
    fileprivate func setupDayAccounts(_ frame:CGRect){
        let DayAccountsView = UITableView(frame: frame)
        DayAccountsView.separatorStyle = .none
        DayAccountsView.register(UINib(nibName: "InComeAccountCell", bundle: nil), forCellReuseIdentifier: "InComeAccountCell")
        DayAccountsView.register(UINib(nibName: "OutComeAccountCell", bundle: nil), forCellReuseIdentifier: "OutComeAccountCell")
        DayAccountsView.dataSource = delegate
        DayAccountsView.delegate = delegate
        DayAccountsView.rowHeight = UITableViewAutomaticDimension
        DayAccountsView.showsVerticalScrollIndicator = false
        
        let midColumnLine = UIView(frame: CGRect(x: self.center.x - 2, y: -300, width: 1, height: 300))
        midColumnLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        DayAccountsView.addSubview(midColumnLine)
        
        tableView = DayAccountsView
        self.addSubview(DayAccountsView)
    }
}
