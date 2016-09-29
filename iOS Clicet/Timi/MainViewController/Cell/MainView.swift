//
//  MainView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

//组件高度

private let ScreenWidthRatio = UIScreen.main.bounds.width / 375
private let ScreenHeightRatio = UIScreen.main.bounds.height / 667

private let StatusBarHeight:CGFloat = 20
private let TopBarHeight:CGFloat = 72
private let IncomeAndExpendBarHeight:CGFloat = 50
private let BottomBarHeight:CGFloat = 60



class MainView: UIView {
    
    
    //供修改总收入和总支出的接口, 1: 总收入， 2: 总支出， 3: 总结余
    var incomeAndExpendLabels: NSArray = NSArray()
    var accountBookBtnView:UICollectionView!
    weak var delegate:MainViewController!
    var icon: UIButton!
    var title: UILabel!
    var upload: UIButton!
    
    
    //MARK: - init (internal)
    convenience init(frame:CGRect, delegate:MainViewController){
        self.init(frame:frame)
        let IncomeAndExpendBarY = StatusBarHeight + TopBarHeight
        let AccountsViewHeight = frame.height - IncomeAndExpendBarY - IncomeAndExpendBarHeight - BottomBarHeight
        let AccountsViewY = IncomeAndExpendBarY + IncomeAndExpendBarHeight
        let BottomBarY = AccountsViewY + AccountsViewHeight
        
        self.backgroundColor = UIColor.white
        self.delegate = delegate
        let contentWidth = frame.width - 30 * ScreenWidthRatio
        //顶部栏
        setupTopBar(CGRect(x: 0, y: StatusBarHeight, width: contentWidth, height: TopBarHeight))
        //收入和支出
        setupIncomeAndExpendBar(CGRect(x: 0, y: IncomeAndExpendBarY, width: contentWidth, height: IncomeAndExpendBarHeight))
        //账本
        setupAccountsView(CGRect(x: 0, y: AccountsViewY, width: contentWidth, height: AccountsViewHeight))
        //底部
        setupBottomBar(CGRect(x: 0, y: BottomBarY, width: contentWidth, height: BottomBarHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCollectionView(){
        self.accountBookBtnView.reloadData()
    }
    
    //MARK: - setup views(private)
    //顶部栏
    fileprivate func setupTopBar(_ frame:CGRect){
        let IconMarginVertical:CGFloat = 15
        let IconMarginLeft:CGFloat = 20
        let IconMarginRight:CGFloat = 10
        let IconWidth:CGFloat = 40
        
        let TitleX = IconWidth + IconMarginLeft + IconMarginRight
        let TitleWidth:CGFloat = 60
        
        let SettingWidth:CGFloat = 26
        let SettingX = frame.width - SettingWidth - 40
        let SettingY:CGFloat = 20
        
        let topBar = UIView(frame: frame)
        
        icon = UIButton(frame: CGRect(x: IconMarginLeft, y: IconMarginVertical, width: IconWidth, height: IconWidth))
        icon.setImage(UIImage(named: "head_icon"), for: UIControlState())
        
        title = UILabel(frame: CGRect(x: TitleX, y: 0, width: TitleWidth, height: frame.height))
        title.textAlignment = .center
        title.text = "未登录"
        
        upload = UIButton(frame: CGRect(x: SettingX, y: SettingY, width: SettingWidth, height: SettingWidth))
        upload.setImage(UIImage(named: "upload"), for: UIControlState())
        
        let sepLine = UIView(frame: CGRect(x: 0, y: frame.height - 1 , width: frame.width, height: 1))
        sepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        //添加到底部栏
        topBar.addSubview(icon)
        topBar.addSubview(title)
        topBar.addSubview(upload)
        topBar.addSubview(sepLine)
        //添加到主界面
        self.addSubview(topBar)
        
    }
    
    //收入和支出
    fileprivate func setupIncomeAndExpendBar(_ frame:CGRect){
        let TriWidth = frame.width / 3
        let LabelMarginLeft:CGFloat = 25
        let LabelMarginTop:CGFloat = 20
        
        let LabelWidth:CGFloat = 60
        let LabelHeight:CGFloat = 15
        
        let staticLabelText = ["总收入", "总支出", "总结余"]
        
        let incomeAndExpend = UIView(frame: frame)
        //生成三个标题
        for i in 0 ..< 3 {
            let LabelX = LabelMarginLeft + CGFloat(i) * TriWidth
            let label = UILabel(frame: CGRect(x: LabelX, y: LabelMarginTop, width: LabelWidth, height: LabelHeight))
            label.text = staticLabelText[i]
            label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            incomeAndExpend.addSubview(label)
        }
        
        //生成三个数值显示label
        for i in 0 ..< 3 {
            let LabelX = LabelMarginLeft + CGFloat(i) * TriWidth
            let label = UILabel(frame: CGRect(x: LabelX, y: LabelMarginTop + LabelHeight , width: LabelWidth, height: LabelHeight))
            label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            label.text = "0.00"
            incomeAndExpendLabels.adding(label)
            incomeAndExpend.addSubview(label)
        }
        
        self.addSubview(incomeAndExpend)
    }
    //账本
    fileprivate func setupAccountsView(_ frame:CGRect){
        
        let AccountsWidth:CGFloat = 80 * ScreenWidthRatio
        let AccountsHeight:CGFloat = 110 * ScreenHeightRatio
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: AccountsWidth, height: AccountsHeight)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.register(UINib(nibName: "AccountBookCell", bundle: nil), forCellWithReuseIdentifier: "AccountBookBtnCell")
        self.accountBookBtnView = collectionView
        
        self.addSubview(collectionView)
    }
    //底部
    fileprivate func setupBottomBar(_ frame:CGRect){
        let bottomBar = UIView(frame: frame)
        let sepLine = UIView(frame: CGRect(x: 0, y: 0 , width: frame.width, height: 1))
        sepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        
        let explore = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        explore.center = CGPoint(x: frame.width/2, y: frame.height/2)
        explore.setImage(UIImage(named: "button_add"), for: UIControlState())
        
        bottomBar.addSubview(sepLine)
        bottomBar.addSubview(explore)
        self.addSubview(bottomBar)
    }
}

