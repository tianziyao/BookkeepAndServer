//
//  BgScrollView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class BgScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.contentOffset.x > 0 && self.contentOffset.x <= self.contentSize.width - self.bounds.width{
            return false
        }
        else{
            return true
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: LineChartViewComponent.self){
            return false
        }
        return true
    }
}
