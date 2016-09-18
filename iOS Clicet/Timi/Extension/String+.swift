//
//  String+.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

extension String{
    var length:Int{
        get {
            return characters.count
        }
    }
}

extension String{
    public static func createFilePathInDocumentWith(fileName:String) -> String? {
        //返回的paths可能不存在
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let docPath = paths.firstObject as? NSString
        return docPath?.stringByAppendingPathComponent(fileName)
    }
    
    public static func createDirectoryInDocumentWith(directoryName:String) -> String?{
        let directoryPath = String.createFilePathInDocumentWith(directoryName) ?? ""
        //在沙盒中创建目录
        if(NSFileManager.defaultManager().fileExistsAtPath(directoryPath) == false){
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("Could not create the DatabaseDoc directory")
            }
        }
        return directoryName
    }
}