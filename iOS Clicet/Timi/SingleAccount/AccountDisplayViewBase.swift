//
//  AccountDisplayViewBase.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let sepLineHeight:CGFloat = 0.5
private let rotateBtnWidth:CGFloat = 60
private let rotateBtnMarginBottom:CGFloat = 10
private let redIndicatorHeight:CGFloat = 30
private let midRoundBtnWidth:CGFloat = 50
private let titleLabelY:CGFloat = 50
private let titleLabelHeight:CGFloat = 50
private let moneyLabelHeight:CGFloat = 50
private let yearLabelHeight:CGFloat = 30
private let yearLabelWidth:CGFloat = 60




class AccountDisplayViewBase: UIView {
    
    //MARK: - properties (public)
    var lineWidth:CGFloat = 15
    var index:Int = 1
    
    weak var pickerDelegate:AKPickerViewDelegate?
    weak var pickerDataSource:AKPickerViewDataSource?
    
    
    var pieChartTotalCost:String{
        get{
            return costBtn.titleLabel?.text ?? ""
        }
        set(newValue){
            costBtn.setTitle("\(newValue)", for: UIControlState())
        }
    }
    
    var pieChartTotalIncome:String{
        get{
            return incomeBtn.titleLabel?.text ?? ""
        }
        set(newValue){
            incomeBtn.setTitle("\(newValue)", for: UIControlState())
        }
    }
    
    //MARK: - properties (private)
    fileprivate var incomeBtn:UIButton!
    fileprivate var costBtn:UIButton!
    fileprivate var yearLabel:UILabel!
    
    //    private var rotateBtn:UIButton!
    fileprivate var pickerView:AKPickerView!
    fileprivate var containerLayer:CAShapeLayer!
    
    fileprivate var radius:CGFloat {
        return self.frame.width / 4
    }
    fileprivate var layerWidth:CGFloat{
        return self.frame.width / 2
    }
    
    //MARK: - init
    init(frame:CGRect, delegate:AKPickerViewDelegate!, dataSource:AKPickerViewDataSource!){
        self.pickerDelegate = delegate
        self.pickerDataSource = dataSource
        
        super.init(frame: frame)
        setupViews(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - operations (internal)
    
    func selectedIncome(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        costBtn.isSelected = !sender.isSelected
    }
    func selectedCost(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        incomeBtn.isSelected = !sender.isSelected
    }
    
    func setYear(_ year:String){
        self.yearLabel.text = year
        self.yearLabel.sizeToFit()
        self.yearLabel.center = CGPoint(x: frame.width / 2, y: 80)
    }
    
    //MARK: - setupViews (private)
    fileprivate func setupViews(_ frame:CGRect){
        let incomeAndCostBtnHeight:CGFloat = 80
        
        setupIncomeAndCostBtn(CGRect(x: 0, y: 0, width: frame.width, height: incomeAndCostBtnHeight))
        setupScrollMonthView(CGRect(x: 0, y: incomeAndCostBtnHeight, width: frame.width, height: incomeAndCostBtnHeight))
    }
    
    fileprivate  func setupIncomeAndCostBtn(_ frame:CGRect){
        
        let btnWidth:CGFloat = 75
        let btnMargin:CGFloat = 15
        let bgView = UIView(frame: frame)
        
        let incomeBtn = createBtn(CGRect(x: btnMargin, y: btnMargin, width: btnWidth, height: btnWidth), title:"总收入\n0.00", action:#selector(AccountDisplayViewBase.selectedIncome(_:)))
        self.incomeBtn = incomeBtn
        let costBtn = createBtn(CGRect(x: frame.width - btnMargin - btnWidth, y: btnMargin, width: btnWidth, height: btnWidth), title:"总支出\n9384.00", action:#selector(AccountDisplayViewBase.selectedCost(_:)))
        costBtn.titleLabel?.textAlignment = .right
        costBtn.isSelected = true
        self.costBtn = costBtn
        let sepline = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: sepLineHeight))
        sepline.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
        bgView.addSubview(sepline)
        bgView.addSubview(incomeBtn)
        bgView.addSubview(costBtn)
        self.addSubview(bgView)
    }
    fileprivate func createBtn(_ frame:CGRect, title:String, action:Selector)->UIButton{
        let btn = UIButton(frame: frame)
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.numberOfLines = 2
        btn.setTitleColor(UIColor.black, for: UIControlState())
        btn.setTitleColor(UIColor.orange, for: .selected)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    fileprivate  func setupScrollMonthView(_ frame:CGRect){
        
        let bgView = UIView(frame: frame)
        
        let pickerView = AKPickerView(frame: CGRect(x: 0, y: 80, width: frame.width, height: frame.height))
        pickerView.delegate = pickerDelegate
        pickerView.dataSource = pickerDataSource
        pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        pickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        pickerView.pickerViewStyle = .wheel
        pickerView.maskDisabled = false
        pickerView.highlightedTextColor = UIColor.orange
        pickerView.interitemSpacing = 20
        pickerView.reloadData()
        pickerView.selectItem(0)
        self.pickerView = pickerView
        
        let sepline = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: sepLineHeight))
        sepline.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
        let yearLabel = UILabel(frame: CGRect(x: 0, y: 0, width: yearLabelWidth, height: yearLabelHeight))
        yearLabel.center = CGPoint(x: frame.width / 2, y: frame.height)
        yearLabel.backgroundColor = UIColor.white
        yearLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        yearLabel.textAlignment = .center
        yearLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        yearLabel.text = "1900年"
        self.yearLabel = yearLabel
        
        bgView.addSubview(sepline)
        bgView.addSubview(yearLabel)
        self.addSubview(bgView)
        self.addSubview(pickerView)
    }
    
}

