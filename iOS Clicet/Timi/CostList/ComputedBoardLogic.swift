//
//  ComputedBoardLogic.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class ComputedBoardLogic:NSObject{
    
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
    
    var okBtn = UIButton()
    
    var computedMoney:computedResultResponder?
    var pressOKClosure:(()->Void)?
    var pressIncomeAndCostClosure:(()->Void)?
    
    fileprivate func outOfDocMode(){
        pressDot = false
        numOfDecimal = 0
    }
    var date = 0
    var remark:String?
    var photoName:String?
    fileprivate func pressOK(){
        if let pressOKClosure = pressOKClosure{
            pressOKClosure()
        }
    }
    fileprivate func pressIncomeAndCost(){
        if let pressIncomeAndCostClosure = pressIncomeAndCostClosure{
            pressIncomeAndCostClosure()
        }
    }
    
    func Compute(_ value:String){
        switch value {
        case "1","2", "3", "4", "5", "6", "7", "8", "9", "0" :
            //点击了+号
            if pressAdd {
                pressAdd = false
                addend = 0
            }
            //计算完一次
            if pressEqual {
                pressEqual = false
                addend = 0
            }
            
            if pressDot {
                numOfDecimal += 1
                
                if numOfDecimal <= 2 {
                    decimal = Float(value)! / Float(pow(10.0, Double(numOfDecimal)))
                    result = addend + decimal
                    if let computedMoney = computedMoney{
                        computedMoney(result)
                    }
                }
                else{
                    //超过两位小数
                }
            }
            else{
                numOfInt += 1
                if numOfInt <= 7 {
                    result = addend * 10.0 + Float(value)!
                    if let computedMoney = computedMoney{
                        computedMoney(result)
                    }
                }
                else{
                    //超过7位
                }
                
            }
            
            addend = result
            
        case "收/支":
            pressIncomeAndCost()
        case "C" :
            summand = 0
            addend = 0
            numOfInt = 0
            outOfDocMode()
            result = 0
            if let computedMoney = computedMoney{
                computedMoney(result)
            }
            okBtn.setTitle("OK", for: UIControlState())
        case "OK" :
            pressOK()
        case ".":
            pressDot = true
        case "+":
            pressAdd = true
            numOfInt = 0
            outOfDocMode()
            if addend != 0 {
                summand += addend
                addend = 0
            }
            result = summand
            if let computedMoney = computedMoney{
                computedMoney(result)
            }
            okBtn.setTitle("=", for: UIControlState())
            
        case "=":
            numOfInt = 0
            outOfDocMode()
            pressEqual = true
            okBtn.setTitle("OK", for: UIControlState())
            if addend != 0 {
                summand += addend
                addend = 0
            }
            result = summand
            if let computedMoney = computedMoney{
                computedMoney(result)
            }
            
        default:
            print("Error")
        }
        
    }
}
