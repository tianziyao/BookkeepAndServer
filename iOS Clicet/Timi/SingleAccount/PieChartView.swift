//
//  PieChartView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import Foundation
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

class PieChartView: AccountDisplayViewBase {
    
    //MARK: - properties (public)
    var layerData:[RotateLayerData]
    
    //MARK: - properties (private)
    fileprivate var itemTitleLabel:UILabel!
    fileprivate var itemMoneyLabel:UILabel!
    fileprivate var itemIconBtn:UIButton!
    fileprivate var itemPercentage:UILabel!
    fileprivate var itemAccountCount:UILabel!
    
    
    fileprivate var layerBgView:UIView!
    fileprivate var dataItem:[CGFloat]!
    
    fileprivate var itemValueAmount:CGFloat{
        var amount:CGFloat = 0
        for value in dataItem{
            amount += value
        }
        if amount == 0 {
            amount = 1
        }
        return amount
    }
    fileprivate var containerLayer:CAShapeLayer!
    
    fileprivate var radius:CGFloat {
        return self.frame.width / 4
    }
    fileprivate var layerWidth:CGFloat{
        return self.frame.width / 2
    }
    
    //MARK: - init
    init(frame:CGRect, layerData:[RotateLayerData], delegate:AKPickerViewDelegate!, dataSource:AKPickerViewDataSource!){
        self.layerData = layerData
        super.init(frame: frame, delegate: delegate, dataSource: dataSource)
        self.setDataItems(layerData)
        setupViews(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - operations (internal)
    func reloadPieChartViewData(_ data:[RotateLayerData]?, year:String, cost:String?, income:String?){
        self.setYear(year)
        if let data = data{
            self.updateByLayerData(data)
        }
        if let cost = cost{
            self.pieChartTotalCost = cost
        }
        if let income = income {
            self.pieChartTotalIncome = income
        }
    }
    
    func reDraw(_ index:Int){
        var curIndex = index - 1
        if index == 0{
            curIndex = dataItem.count - 1
        }
        
        var rotateRadian = dataItem[curIndex] / itemValueAmount + dataItem[index] / itemValueAmount
        rotateRadian = -rotateRadian * CGFloat(M_PI)
        rotateContainerLayerWithRadian(rotateRadian)
    }
    
    func rotateAction(_ sender:UIButton?){
        if dataItem.count > 1{
            reDraw(index % dataItem.count)
            reloadDataInPieChartView(layerData[index])
            index += 1
            if index >= dataItem.count{
                index = 0
            }
        }
    }
    
    func setDataItems(_ layerDatas:[RotateLayerData]){
        var moneyItems = [CGFloat]()
        for item in layerDatas{
            let money = Float(item.money) ?? 0
            moneyItems.append(CGFloat(money))
        }
        self.dataItem = moneyItems
    }
    func reloadDataInPieChartView(_ layerData: RotateLayerData){
        
        self.itemTitleLabel.text = layerData.title
        self.itemMoneyLabel.text = layerData.money
        self.itemIconBtn.setImage(UIImage(named: layerData.icon), for: UIControlState())
        self.itemPercentage.text = layerData.percent
        self.itemAccountCount.text = layerData.count
    }
    
    func updateByLayerData(_ data:[RotateLayerData]){
        layerData = data
        setDataItems(data)
        index = 1
        
        self.containerLayer.removeFromSuperlayer()
        self.containerLayer = setupContainerLayer(CGRect(x: 0, y: 160, width: frame.width, height: frame.height - 160))
        self.layerBgView.layer.addSublayer(self.containerLayer)
        if layerData.count > 0{
            reloadDataInPieChartView(layerData[0])
        }
    }
    
    //MARK: - setupViews (private)
    fileprivate func setupViews(_ frame:CGRect){
        let incomeAndCostBtnHeight:CGFloat = 80
        let layersHeight = frame.height - 2 * incomeAndCostBtnHeight
        
        setupRotateLayers(CGRect(x: 0, y: incomeAndCostBtnHeight * 2, width: frame.width, height: layersHeight))
        
        if layerData.count > 0{
            reloadDataInPieChartView(layerData[0])
        }
    }
    
    fileprivate  func setupRotateLayers(_ frame:CGRect){
        
        let bgView = UIView(frame: frame)
        self.layerBgView = bgView
        
        let titleLabel = setupTitleLabel(frame)
        let moneyLabel = setupMoneyLabel(frame)
        let redIndicator = setupIndicator(frame)
        let midRoundBtn = setupIconBtn(frame)
        let midPercentLabel = setupPercentageLabel(frame)
        let countLabel = setupCountLabel(frame)
        let rotateBtn = setupRotateBtn(frame)
        let containerLayer = setupContainerLayer(frame)
        
        bgView.layer.addSublayer(containerLayer)
        bgView.addSubview(countLabel)
        bgView.addSubview(midPercentLabel)
        bgView.addSubview(midRoundBtn)
        bgView.addSubview(moneyLabel)
        bgView.addSubview(titleLabel)
        bgView.addSubview(redIndicator)
        bgView.addSubview(rotateBtn)
        self.addSubview(bgView)
    }
    
    func setupContainerLayer(_ frame:CGRect)->CAShapeLayer {
        let containerLayer = CAShapeLayer()
        containerLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        containerLayer.addSublayer(generateLayers(frame, color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8), percentageStart: 0, percentageEnd: 1))
        var percentageStart:CGFloat = 0
        var percentageEnd:CGFloat = 0
        
        for (_, value) in dataItem.enumerated(){
            percentageEnd += value / itemValueAmount
            let pieLayer = generateLayers(frame, color: nil, percentageStart: percentageStart, percentageEnd: percentageEnd)
            containerLayer.addSublayer(pieLayer)
            percentageStart = percentageEnd
        }
        self.containerLayer = containerLayer
        
        if layerData.count > 0{
            let initRotateRadian = -CGFloat(M_PI) * dataItem[0] / itemValueAmount
            rotateContainerLayerWithRadian(initRotateRadian)
        }
        
        return containerLayer
    }
    
    fileprivate func setupTitleLabel(_ frame:CGRect)->UILabel{
        let titleLabel = UILabel(frame: CGRect(x: frame.width/2 - titleLabelHeight, y: titleLabelY, width: titleLabelHeight * 2, height: titleLabelHeight))
        titleLabel.textAlignment = .center
        itemTitleLabel = titleLabel
        return titleLabel
    }
    fileprivate func setupMoneyLabel(_ frame:CGRect)->UILabel{
        let moneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: moneyLabelHeight * 2, height: moneyLabelHeight))
        moneyLabel.textAlignment = .center
        moneyLabel.center = CGPoint(x: frame.width/2, y: titleLabelHeight + titleLabelY)
        itemMoneyLabel = moneyLabel
        return moneyLabel
    }
    fileprivate func setupIndicator(_ frame:CGRect)->UIView{
        let redIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: redIndicatorHeight))
        redIndicator.center = CGPoint(x: frame.width/2, y: frame.height/2 - frame.width/4 - redIndicatorHeight )
        redIndicator.backgroundColor = UIColor.red
        return redIndicator
    }
    
    fileprivate func setupIconBtn(_ frame:CGRect)->UIButton{
        let midRoundBtn = UIButton(frame: CGRect(x: 0, y: 0, width: midRoundBtnWidth, height: midRoundBtnWidth))
        midRoundBtn.center = CGPoint(x: frame.width/2, y: frame.height/2 - midRoundBtnWidth/2)
        itemIconBtn = midRoundBtn
        return midRoundBtn
    }
    fileprivate func setupPercentageLabel(_ frame:CGRect)->UILabel{
        let midPercentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: midRoundBtnWidth, height: midRoundBtnWidth))
        midPercentLabel.center = CGPoint(x: frame.width/2, y: frame.height/2 + midRoundBtnWidth/2)
        midPercentLabel.textAlignment = .center
        itemPercentage = midPercentLabel
        return midPercentLabel
    }
    
    
    
    fileprivate func setupCountLabel(_ frame:CGRect)->UILabel {
        let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: midRoundBtnWidth, height: midRoundBtnWidth))
        countLabel.center = CGPoint(x: frame.width/2, y: frame.height/2 + frame.width/4 + 40)
        countLabel.textAlignment = .center
        itemAccountCount = countLabel
        return countLabel
    }
    
    fileprivate func setupRotateBtn(_ frame:CGRect)->UIButton {
        let rotateBtnX = (frame.width - rotateBtnWidth) / 2
        let rotateBtnY =  frame.height - rotateBtnMarginBottom - rotateBtnWidth
        let rotateBtn = UIButton(frame: CGRect(x: rotateBtnX, y: rotateBtnY, width: rotateBtnWidth, height: rotateBtnWidth))
        rotateBtn.setImage(UIImage(named: "btn_pieChart_rotation"), for: UIControlState())
        rotateBtn.addTarget(self, action: #selector(PieChartView.rotateAction(_:)), for: .touchUpInside)
        return rotateBtn
    }
    
    fileprivate func gradientMaskAnimation(_ frame:CGRect){
        
        containerLayer.mask = generateLayers(frame, color: nil, percentageStart: 0, percentageEnd: 1)
        let gradientAnimation = CABasicAnimation(keyPath: "strokeEnd")
        gradientAnimation.fromValue = 0
        gradientAnimation.toValue = 1
        gradientAnimation.duration = 0.5
        gradientAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        containerLayer.mask?.add(gradientAnimation, forKey: "gradientAnimation")
    }
    
    fileprivate func generateLayers(_ frame: CGRect, color:UIColor?, percentageStart:CGFloat, percentageEnd:CGFloat) -> CAShapeLayer{
        
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3 * M_PI_2) , clockwise: true)
        let pieLayer = CAShapeLayer()
        pieLayer.path = path.cgPath
        pieLayer.lineWidth = lineWidth
        if let col = color?.cgColor{
            pieLayer.strokeColor = col
        }
        else{
            pieLayer.strokeColor = UIColor(hue: percentageEnd, saturation: 0.5, brightness: 0.75, alpha: 1.0).cgColor
        }
        
        pieLayer.fillColor = nil
        pieLayer.strokeStart = percentageStart
        pieLayer.strokeEnd = percentageEnd
        return pieLayer
    }
    
    fileprivate func rotateContainerLayerWithRadian(_ radian:CGFloat){
        
        let myAnimation = CABasicAnimation(keyPath: "transform.rotation")
        let myRotationTransform = CATransform3DRotate(containerLayer.transform, radian, 0, 0, 1)
        if let rotationAtStart = containerLayer.value(forKeyPath: "transform.rotation") {
            
            myAnimation.fromValue = (rotationAtStart as AnyObject).floatValue
            myAnimation.toValue = CGFloat((rotationAtStart as AnyObject).floatValue) + radian
        }
        containerLayer.transform = myRotationTransform
        myAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        containerLayer.add(myAnimation, forKey: "transform.rotation")
    }
    
}
