//
//  NSObject+.swift
//  Timi
//
//  Created by 田子瑶 on 16/9/1.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import Foundation

extension NSObject{
    var keyValues:[String:AnyObject]?{                   //获取一个模型对应的字典
        get{
            var result = [String: AnyObject]()           //保存结果
            var classType:AnyClass = self.classForCoder
            while("NSObject" !=  "\(classType)" ){
                var count:UInt32 = 0
                let properties = class_copyPropertyList(classType, &count)
                for i in 0..<count{
                    let property = properties[Int(i)]
                    let propertyKey = String.fromCString(property_getName(property))!         //模型中属性名称
                    let propertyType = String.fromCString(property_getAttributes(property))!  //模型中属性类型
                    
                    if "description" == propertyKey{ continue }   //描述，不是属性
                    
                    let tempValue:AnyObject!  = self.valueForKey(propertyKey)
                    if  tempValue == nil { continue }
                    
                    if let _ =  HEFoundation.getType(propertyType) {         //1,自定义的类
                        result[propertyKey] = tempValue.keyValues
                    }else if (propertyType.containsString("NSArray")){       //2, 数组, 将数组中的模型转成字典
                        result[propertyKey] = tempValue.keyValuesArray       //3， 基本数据
                    }else{
                        result[propertyKey] = tempValue
                    }
                }
                free(properties)
                classType = classType.superclass()!
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}

class HEFoundation {
    
    static let set = NSSet(array: [
        NSURL.classForCoder(),
        NSDate.classForCoder(),
        NSValue.classForCoder(),
        NSData.classForCoder(),
        NSError.classForCoder(),
        NSArray.classForCoder(),
        NSDictionary.classForCoder(),
        NSString.classForCoder(),
        NSAttributedString.classForCoder()
        ])
    static let  bundlePath = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as! String
    
    /*** 判断某个类是否是 Foundation中自带的类 */
    class func isClassFromFoundation(c:AnyClass)->Bool {
        var  result = false
        if c == NSObject.classForCoder(){
            result = true
        }else{
            set.enumerateObjectsUsingBlock({ (foundation,  stop) -> Void in
                if  c.isSubclassOfClass(foundation as! AnyClass) {
                    result = true
                    stop.initialize(true)
                }
            })
        }
        return result
    }
    
    /** 很据属性信息， 获得自定义类的 类名*/
    /**
     let propertyType = String.fromCString(property_getAttributes(property))! 获取属性类型
     到这个属性的类型是自定义的类时， 会得到下面的格式： T+@+"+..+工程的名字+数字+类名+"+,+其他,
     而我们想要的只是类名，所以要修改这个字符串
     */
    class func getType(code:String)->String?{
        
        if !code.containsString(bundlePath){ //不是自定义类
            return nil
        }
        var code = code.componentsSeparatedByString("\"")[1]
        if let range = code.rangeOfString(bundlePath){
            code = code.substringFromIndex(range.endIndex)
            var numStr = "" //类名前面的数字
            for c:Character in code.characters{
                if c <= "9" && c >= "0"{
                    numStr+=String(c)
                }
            }
            if let numRange = code.rangeOfString(numStr){
                code = code.substringFromIndex(numRange.endIndex)
            }
            return bundlePath+"."+code
        }
        return nil
    }
}

extension NSArray{  //数组的拓展
    var keyValuesArray:[AnyObject]?{
        get{
            var result = [AnyObject]()
            for item in self{
                if !HEFoundation.isClassFromFoundation(item.classForCoder){ //1,自定义的类
                    let subKeyValues:[String:AnyObject]! = item.keyValues
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues)
                }else if item.classForCoder == NSArray.classForCoder(){    //2, 如果item 是数组
                    let subKeyValues:[AnyObject]! = item.keyValuesArray
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues)
                }else{                                                     //3, 基本数据类型
                    result.append(item)
                }
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}
