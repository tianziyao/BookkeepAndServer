//
//  BgScrollView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class BgScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.contentOffset.x > 0 && self.contentOffset.x <= self.contentSize.width - self.bounds.width{
            return false
        }
        else{
            return true
        }
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view.isKindOfClass(LineChartViewComponent){
            return false
        }
        return true
    }
}
