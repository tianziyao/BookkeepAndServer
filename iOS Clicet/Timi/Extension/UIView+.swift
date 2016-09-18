//
//  UIView+.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

extension UIView{
    var height:CGFloat{
        get{
            return self.frame.height
        }
        set(newValue){
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    var width:CGFloat{
        get{
            return self.frame.width
        }
        set(newValue){
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    var x:CGFloat{
        get{
            return self.frame.origin.x
        }
        set(newValue){
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    var y:CGFloat{
        get{
            return self.frame.origin.y
        }
        set(newValue){
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    var centerX:CGFloat{
        get{
            return self.center.x
        }
        set(newValue){
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    var centerY:CGFloat{
        get{
            return self.center.y
        }
        set(newValue){
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
}