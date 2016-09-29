//
//  PieChartModel.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//data displayed in piechartview
class RotateLayerData:NSObject {
    let title:String
    let money:String
    let icon:String
    var percent:String
    let count:String
    
    init(title:String, money:String, icon:String, percent:String, count:String){
        self.title = title
        self.money = money
        self.icon = icon
        self.percent = percent
        self.count = count
        super.init()
    }
}


class LineChartInfoData:NSObject{
    let money:Float
    let date:String
    let week:String
    init(money:Float, date:String, week:String){
        self.money = money
        self.date = date
        self.week = week
        super.init()
    }
}

class BudgetData:NSObject{
    let budgetNum:String!
    let costNum:String!
    let settleDay:String!
    
    var surpluNum:String{
        let budget = Float(budgetNum) ?? 0
        let cost = Float(costNum) ?? 0
        let tmp = budget - cost
        return String(format: "%.2f", tmp)
    }
    var percentNum:String{
        let surplus = Int(surpluNum) ?? 0
        let budget = Int(budgetNum) ?? 0
        if surplus < 0 || budget == 0 {
            return "0%"
        }
        let tmp = surplus * 100 / budget
        return "\(tmp)%"
    }
    
    init(budget:String, cost:String, day:String){
        budgetNum = budget
        costNum = cost
        settleDay = day
        super.init()
    }
}

private let secondsPerDay:TimeInterval = 86400
private let weekChinese = ["日", "一", "二", "三", "四", "五", "六"]
private let allDataKey:Int = -1

class PieChartModel: NSObject {
    
    //MARK: - properties (public)
    var yearArray = [String]()
    var monthArray:[Int]
    var monthTotalMoney:[String]
    
    var budgetModelData:BudgetData!
    var budget:CGFloat = 0
    var settleDay:Int = 1
    
    var lineChartTableViewData = [RotateLayerData]()
    var lineChartInfoArray = [LineChartInfoData]()
    var rotateLayerDataArray:[RotateLayerData]
    
    var monthDic = [Int:[AccountItem]]()                    //while the key is month and array is items
    var mergedMonthlyData = [Int: [String:[AccountItem]]]() //the final data structrue
    
    var lineChartMoneyArray:[Float]{
        var tmp = [Float]()
        for value in lineChartInfoArray{
            tmp.append(value.money)
        }
        return tmp
    }
    var pieChartPickerData:[String]{
        var items = [String]()
        items.append("全部")
        for value in monthArray{
            if value != allDataKey{
                let interval = TimeInterval(value)
                let month = Date.intervalToDateComponent(interval).month
                items.append("\(month)月")
            }
        }
        return items
    }
    var lineChartPickerData:[String]{
        var items = [String]()
        for value in monthArray{
            if value != allDataKey{
                let interval = TimeInterval(value)
                let month = Date.intervalToDateComponent(interval).month
                items.append("\(month)月")
            }
        }
        return items
    }
    
    //MARK: - properties (private)
    fileprivate var initDBName:String
    fileprivate var dbData:[AccountItem]{
        return AccoutDB.selectDataOrderByDate(initDBName)
    }
    
    //MARK: - init
    init(dbName:String){
        initDBName = dbName
        let rotateItem = RotateLayerData(title: "一般", money: "0.00", icon: "type_big_1", percent: "100%", count: "0笔")
        rotateLayerDataArray = [rotateItem]
        let comp = Date.dateToDateComponent(Date())
        yearArray = ["\(comp.year)年", "\(comp.year)年"]
        monthArray = [allDataKey, Int(Date().timeIntervalSince1970)]
        monthTotalMoney = ["总支出\n0.00", "月支出\n0.00"]
        super.init()
        //deal with raw data
        groupDateByMonth()
        mergeEachMetaData()
        setRotateLayerDataArrayAtIndex(0)
        setLineChartTableViewDataAtIndex(0)
        setLineChartInfoArrayAtIndex(0)
        setBudgetDataforUse()
    }
    //MARK: - operation(internal)
    func setRotateLayerDataArrayAtIndex(_ i:Int){
        if let dataItem = getMergedMonthlyDataAtIndex(i){
            self.rotateLayerDataArray = getLayerDataItem(dataItem)
        }
    }
    func setBudgetDataforUse(){
        let tmpBudget = String(format: "%.2f", budget)
        let tmpSettleDay = Date.numberOfDaysInMonthWithDate(Date()) - settleDay
        let tmpCost = monthTotalMoney[1].substring(from: monthTotalMoney[1].characters.index(monthTotalMoney[1].startIndex, offsetBy: 4))
        budgetModelData = BudgetData(budget: tmpBudget, cost: "\(tmpCost)", day: "\(tmpSettleDay)")
    }
    
    func getLayerDataItem(_ dataItem:[String:[AccountItem]])->[RotateLayerData] {
        var amount:Float = 0
        var layerData = [CGFloat]()
        var array = [RotateLayerData]()
        for (_, items) in dataItem{
            var value:Float = 0
            var title = ""
            var money = ""
            var icon = ""
            let count = "\(items.count)笔"
            for item in items{
                value += Float(item.money) ?? 0
                title = item.iconTitle
                icon = item.iconName
            }
            money = String(format: "%.2f", value)
            amount += value
            layerData.append(CGFloat(value))
            array.append(RotateLayerData(title: title, money: money, icon: icon, percent: "", count: count))
        }
        
        for (i,data) in array.enumerated() {
            let tmpPercent = Float(layerData[i]) / amount
            let percentage = "\(Int(tmpPercent * 100))%"
            data.percent = percentage
        }
        
        array.sort{(item1, item2)->Bool in
            let item1MoneyFloat = Float(item1.money)
            let item2MoneyFloat = Float(item2.money)
            return item1MoneyFloat > item2MoneyFloat
        }
        return array
    }
    func setLineChartTableViewDataAtIndex(_ i:Int){
        if let dataItem = getMergedMonthlyDataAtIndex(i + 1){
            self.lineChartTableViewData = getLayerDataItem(dataItem)
        }
    }
    
    func setLineChartInfoArrayAtIndex(_ i:Int){
        
        if i + 1 < monthArray.count{
            let month = monthArray[i + 1]
            let tmpDate =  Date(timeIntervalSince1970: TimeInterval(month))
            let numOfDays = Date.numberOfDaysInMonthWithDate(tmpDate)
            var firstDateOfMonth = Date.getFirstDayOfMonthWithDate(tmpDate)!
            var tmpLineChartInfoArray = [LineChartInfoData]()
            
            for _ in 1...numOfDays{
                
                let compRef = (Calendar.current as NSCalendar).components([.year, .month, .day, .weekday], from: firstDateOfMonth)
                var money:Float = 0.0
                let date = "\(compRef.month)月\(compRef.day)日"
                let week = "星期\(weekChinese[compRef.weekday - 1])"
                
                if let item = monthDic[month]{
                    let reverseItem = item.reversed()
                    for value in reverseItem{
                        let itemComp = getCompWithDate(value.date)
                        if compRef.day == itemComp.day{
                            money += Float(value.money) ?? 0
                        }
                    }
                }
                
                tmpLineChartInfoArray.append(LineChartInfoData(money: money, date: date, week: week))
                let nextDateInterval = firstDateOfMonth.timeIntervalSince1970 + secondsPerDay
                firstDateOfMonth = Date(timeIntervalSince1970: nextDateInterval)
            }
            lineChartInfoArray = tmpLineChartInfoArray
        }
    }
    
    
    
    func getMergedMonthlyDataAtIndex(_ index:Int) -> [String:[AccountItem]]? {
        guard index < monthArray.count else{
            return nil
        }
        let key = monthArray[index]
        return mergedMonthlyData[key]
    }
    
    //MARK: - methods (private)
    fileprivate func getCompWithDate(_ date:Int)->DateComponents{
        let itemDate = Date(timeIntervalSince1970: TimeInterval(date))
        let itemComp = (Calendar.current as NSCalendar).components([.year, .month, .day, .weekday], from: itemDate)
        return itemComp
    }
    
    fileprivate func groupDateByMonth(){
        
        
        //if there is any data in database
        if dbData.count > 0 {
            var tmpYearArray = [String]()
            var tmpMonthArray = [Int]()
            var tmpMonthDic = [Int:[AccountItem]]()
            var tmpMonthTotalMoney = [String]()
            var eachMonthItems = [AccountItem]()
            var monthMoney:Float = 0
            var totalMoney:Float = 0
            
            var dateCompRef = Date.intervalToDateComponent(TimeInterval(dbData[0].date))
            var monthKey = dbData[0].date
            tmpYearArray.append("\(dateCompRef.year)年")
            for (_, value) in dbData.enumerated(){
                let dateComp = Date.intervalToDateComponent(TimeInterval(value.date))
                totalMoney += Float(value.money) ?? 0
                
                if dateCompRef.year == dateComp.year && dateCompRef.month == dateComp.month {
                    eachMonthItems.append(value)
                    monthMoney += Float(value.money) ?? 0
                }
                else{
                    tmpYearArray.append("\(dateComp.year)年")
                    tmpMonthArray.append(monthKey)
                    tmpMonthDic[monthKey] = eachMonthItems
                    tmpMonthTotalMoney.append(String(format: "月支出\n%.2f", monthMoney))
                    monthMoney = Float(value.money) ?? 0
                    
                    eachMonthItems.removeAll()          //remove all items in eachMonthItems
                    monthKey = value.date
                    eachMonthItems.append(value)        //add current dbData[i]
                    
                    dateCompRef = dateComp              //change dateCompRef to current dbData[i]
                }
            }
            //put the last key-value into monthDic
            tmpMonthArray.append(monthKey)
            tmpMonthTotalMoney.append(String(format: "月支出\n%.2f", monthMoney))
            tmpMonthDic[monthKey] = eachMonthItems
            
            tmpMonthTotalMoney.insert(String(format: "总支出\n%.2f", totalMoney), at: 0)
            
            
            yearArray = tmpYearArray
            monthTotalMoney = tmpMonthTotalMoney
            monthArray = tmpMonthArray
            monthDic = tmpMonthDic
        }
    }
    fileprivate func mergeSameItem(_ data:[AccountItem])->[String:[AccountItem]]{
        
        var isChecked = [Bool](repeating: false, count: data.count)
        var dataDic = [String : [AccountItem]]()
        for i in 0 ..< data.count {
            if isChecked[i] == false {
                let imageRef = data[i].iconName
                var tmpData = [AccountItem]()
                for (j,_) in data.enumerated(){
                    if isChecked[j] == false && imageRef == data[j].iconName{
                        tmpData.append(data[j])
                        isChecked[j] = true
                    }
                }
                dataDic[imageRef] = tmpData
            }
        }
        return dataDic
    }
    fileprivate func mergeEachMetaData(){
        if dbData.count > 0 {
            //all
            if yearArray[yearArray.endIndex - 1] == yearArray[yearArray.startIndex]{
                let allYear = yearArray[yearArray.startIndex]
                yearArray.insert(allYear, at: 0)
            }
            else{
                let allYear = yearArray[yearArray.endIndex - 1] + "~" + yearArray[yearArray.startIndex]
                yearArray.insert(allYear, at: 0)
            }
            mergedMonthlyData[allDataKey] = mergeSameItem(dbData)
            monthArray.insert(allDataKey, at: 0)
            //monthly
            for (key, monthDataArray) in monthDic{
                mergedMonthlyData[key] = mergeSameItem(monthDataArray)
            }
        }
    }
}
