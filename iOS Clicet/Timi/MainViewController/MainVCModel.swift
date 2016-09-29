//
//  MainVCModel.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class AccountBookBtn:NSObject, NSCoding{
    
    var btnTitle:String
    var accountCount:String
    var backgrountImageName:String
    var selectedFlag:Bool
    var dataBaseName:String
    
    init(title:String, count:String, image:String, flag:Bool, dbName:String){
        self.btnTitle = title
        self.accountCount = count
        self.backgrountImageName = image
        self.selectedFlag = flag
        self.dataBaseName = dbName
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let btnTitle = aDecoder.decodeObject(forKey: "btnTitle") as? String ,
            let count = aDecoder.decodeObject(forKey: "accountCount") as? String,
            let image = aDecoder.decodeObject(forKey: "backgrountImageName") as? String,
            let dbName = aDecoder.decodeObject(forKey: "dataBaseName") as? String
            else{ return nil }
        self.init(title: btnTitle , count: count, image: image, flag: aDecoder.decodeBool(forKey: "selectedFlag"), dbName: dbName)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.btnTitle, forKey: "btnTitle")
        aCoder.encode(self.accountCount, forKey: "accountCount")
        aCoder.encode(self.backgrountImageName, forKey: "backgrountImageName")
        aCoder.encode(self.selectedFlag, forKey: "selectedFlag")
        aCoder.encode(self.dataBaseName, forKey: "dataBaseName")
    }
}

let UniqAccountPath = String.createFilePathInDocumentWith(firmAccountPath) ?? ""


class MainVCModel:NSObject{
    
    var totalAccountsIncome:Float = 0
    var totalAccountsCost:Float = 0
    var totalAccountsRemain:Float = 0
    //给collectionview用
    dynamic var accountsBtns:[AccountBookBtn] = []
    
    override init(){
        super.init()
        self.initWithAccountsBtns()
    }
    fileprivate func initWithAccountsBtns(){
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        if let accountsBtns = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [AccountBookBtn]{
            for i in 0...accountsBtns.count - 2{
                accountsBtns[i].accountCount = String(AccoutDB.itemCount(accountsBtns[i].dataBaseName))+"笔"
            }
            self.accountsBtns.removeAll()
            for element in accountsBtns{
                self.accountsBtns += [element]
            }
        }
    }
    
    func reloadModelData(){
        //更新按钮的itemCount
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        if let accountsBtns = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [AccountBookBtn]{
            for i in 0...accountsBtns.count - 2{
                accountsBtns[i].accountCount = String(AccoutDB.itemCount(accountsBtns[i].dataBaseName))+"笔"
            }
            
            self.accountsBtns.removeAll()
            for element in accountsBtns{
                self.accountsBtns += [element]
            }
        }
        //更新金额
    }
    
    //更新数组中的flag，互斥
    func showFlagWithIndex(_ index:Int){
        for i in 0...accountsBtns.count - 1{
            if i == index{
                accountsBtns[i].selectedFlag = true
                NSKeyedArchiver.archiveRootObject(accountsBtns, toFile: UniqAccountPath)
            }
            else{
                accountsBtns[i].selectedFlag = false
                NSKeyedArchiver.archiveRootObject(accountsBtns, toFile: UniqAccountPath)
            }
        }
    }
    
    //查找
    func getItemInfoAtIndex(_ i:Int)->AccountBookBtn?{
        guard i < accountsBtns.count else{return nil}
        return accountsBtns[i]
    }
    //增加
    func addBookItemByAppend(_ item:AccountBookBtn){
        accountsBtns.insert(item, at: accountsBtns.count - 1)
        NSKeyedArchiver.archiveRootObject(accountsBtns, toFile: UniqAccountPath)
    }
    //删除
    func removeBookItemAtIndex(_ i:Int){
        if i < accountsBtns.count{
            accountsBtns.remove(at: i)
            NSKeyedArchiver.archiveRootObject(accountsBtns, toFile: UniqAccountPath)
        }
    }
    //更新
    func updateBookItem(_ item:AccountBookBtn, atIndex index:Int){
        if index < accountsBtns.count{
            removeBookItemAtIndex(index)
            accountsBtns.insert(item, at: index)
            NSKeyedArchiver.archiveRootObject(accountsBtns, toFile: UniqAccountPath)
        }
    }
}
