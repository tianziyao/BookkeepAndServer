//
//  NSDate+.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

extension NSDate{
    class func intervalToChinaCalander(interval:NSTimeInterval) ->String{
        let date = NSDate(timeIntervalSince1970: interval)
        let cal = NSCalendar.currentCalendar()
        let calCom = cal.components([.Year, .Month, .Day], fromDate: date)
        let currentDate = "\(calCom.year)年\(calCom.month)月\(calCom.day)日"
        return currentDate
    }
    class func intervalToDateComponent(interval:NSTimeInterval) -> NSDateComponents{
        let date = NSDate(timeIntervalSince1970: interval)
        return dateToDateComponent(date)
    }
    class func dateToDateComponent(date:NSDate) -> NSDateComponents{
        let cal = NSCalendar.currentCalendar()
        let calCom = cal.components([.Year, .Month, .Day], fromDate: date)
        return calCom
    }
    
    class func numberOfDaysInMonthWithDate(date:NSDate)->Int{
        let comp = NSCalendar.currentCalendar().rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        return comp.length
    }
    class func numberOfDaysInMonthWithInterval(interval:NSTimeInterval)->Int{
        let date = NSDate(timeIntervalSince1970: interval)
        return numberOfDaysInMonthWithDate(date)
    }
    class func getFirstDayOfMonthWithDate(date:NSDate)->NSDate?{
        let cal = NSCalendar.currentCalendar()
        let comp = cal.components([.Year, .Month, .Day], fromDate: date)
        comp.day = 1
        return cal.dateFromComponents(comp)
    }
}

