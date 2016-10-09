//
//  UITextBox.swift
//  UITest
//
//  Created by 李招利 on 14/7/10.
//  Copyright (c) 2014年 慧趣工作室. All rights reserved.
//

import UIKit

//enum UITextBoxContentType {
//    case AnyChar
//    case Number
//    case Integer
//    case EMail
//    case Phone
//    case Telephone
//    case MobilePhone
//    case CustomType
//}


enum UITextBoxHighlightState {
    case `default`
    case validator  (String)    // 状态提示文字
    case warning    (String)    // 状态提示文字
    case wrong      (String)    // 状态提示文字
}

@IBDesignable

class UITextBox: UITextField {
    
    @IBInspectable var wrongColor:UIColor       = UIColor(number: 0xFFEEEE) // 淡红色
    @IBInspectable var warningColor:UIColor     = UIColor(number: 0xFFFFCC) // 淡黄色
    @IBInspectable var validatorColor:UIColor   = UIColor(number: 0xEEFFEE) // 淡绿色
    @IBInspectable var highlightColor:UIColor   = UIColor(number: 0xEEF7FF) // 淡蓝色
    
    @IBInspectable var animateDuration:CGFloat = 0.4
    weak var placeholderLabel:UILabel?
    
    @NSCopying fileprivate var _backgroundColor: UIColor? = nil
    override var backgroundColor: UIColor? {
        set {
            _backgroundColor = newValue
            super.backgroundColor = self.getHighlightColor(self.highlightState)
        }
        get {
            return _backgroundColor
        }
    }
    override var attributedPlaceholder: NSAttributedString? {
    didSet {
        if let label = placeholderLabel {
            label.attributedText = super.attributedPlaceholder
            self.layoutSubviews()
        }
    }
    }
    override var placeholder:String? {
    didSet {
        if let label = placeholderLabel {
            label.text = super.placeholder
            self.layoutSubviews()
        }
    }
    }
    
    
    fileprivate var _highlightState:UITextBoxHighlightState {
        return text == nil || text == "" ? .default : highlightState
    }
    var highlightState:UITextBoxHighlightState = .default {
    didSet {
        if let label = placeholderLabel {
            setHighlightText(label, state: _highlightState)
            self.layoutSubviews()
        }
        UIView.animate(withDuration: TimeInterval(animateDuration), animations: {
            super.backgroundColor = self.getHighlightColor(self._highlightState)
            
        }) 
    }
    }
    
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.addTarget(self, action: Selector("editingChanged"), forControlEvents: UIControlEvents.EditingChanged);
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.addTarget(self, action: Selector("editingChanged"), forControlEvents: UIControlEvents.EditingChanged);
//    }
//    
//    func editingChanged() {
//        print("editingChanged:\(text)")
//    }
    
    //获得焦点时高亮动画
    override func becomeFirstResponder() -> Bool {
        return animationFirstResponder(super.becomeFirstResponder())
    }
    
    //失去焦点时取消高亮动画
    override func resignFirstResponder() -> Bool {
        return animationFirstResponder(super.resignFirstResponder())
    }
    
    //
    fileprivate func animationFirstResponder(_ isFirstResponder:Bool) -> Bool {
        UIView.animate(withDuration: TimeInterval(animateDuration), animations: {
            let color = self.getHighlightColor(self._highlightState)
            super.backgroundColor = color
            self.placeholderLabel?.textColor = self.getTextColorWithHighlightColor(color)
        }) 
        return isFirstResponder
    }
    
    
    //调整子控件布局
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = super.placeholderRect(forBounds: bounds)
        if isFirstResponder {
            layoutPlaceholderLabel(rect,false)
        } else if text == nil || text == "" {
            layoutPlaceholderLabel(rect,true)
        } else {
            layoutPlaceholderLabel(rect,false)
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView!)  {
        super.willMove(toSuperview: newSuperview)
        if placeholderLabel == nil {
            let rect = super.placeholderRect(forBounds: bounds)
            let label = UILabel(frame: rect)
            label.font = self.font
            setHighlightText(label, state: self._highlightState)
            placeholderLabel = label
            self.addSubview(label);
        }
    }
    
    override func removeFromSuperview() {
        self.placeholderLabel?.removeFromSuperview()
        self.placeholderLabel = nil
        super.removeFromSuperview()
    }
    

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.placeholderRect(forBounds: bounds)
        if placeholderLabel == nil {
            let label = UILabel(frame: rect)
            label.textColor = UIColor(white: 0.7, alpha: 1.0)
            label.font = self.font
            placeholderLabel = label
            addSubview(label)
        }
        setHighlightText(placeholderLabel!, state: self._highlightState)
        layoutPlaceholderLabel(rect,!isFirstResponder)
        return CGRect.zero
    }
    
    
    //布局提示文本
    func layoutPlaceholderLabel(_ rect: CGRect,_ left: Bool = false) {
        guard let label = placeholderLabel else {
            return
        }
        
        if left {
            UIView.animate(withDuration: TimeInterval(animateDuration), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                label.frame = rect;
            }, completion: nil)
        } else {
            let size = label.sizeThatFits(rect.size)
            var frame = rect
            frame.size.width = size.width
            frame.size.height = rect.height
            //print("super.clearButtonRectForBounds(bounds):\(super.clearButtonRectForBounds(bounds))")
            frame.origin.x = super.clearButtonRect(forBounds: bounds).minX - size.width
            UIView.animate(withDuration: TimeInterval(animateDuration), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                label.frame = frame;
            }, completion: nil)
        }
    }
    
    fileprivate func setHighlightText(_ label:UILabel, state:UITextBoxHighlightState) {
        switch state {
        case .wrong(let errorText):
            label.textColor = getTextColorWithHighlightColor(wrongColor)
            label.text = errorText
        case .warning(let warningText):
            label.textColor = getTextColorWithHighlightColor(warningColor)
            label.text = warningText
        case .validator(let validatorText):
            label.textColor = getTextColorWithHighlightColor(validatorColor)
            label.text = validatorText
        default:
            if let attributedPlaceholder = self.attributedPlaceholder {
                label.attributedText = attributedPlaceholder
            } else {
                label.text = self.placeholder
            }
            label.textColor = getTextColorWithHighlightColor(getHighlightColor(_highlightState))
        }
    }
    fileprivate func getTextColorWithHighlightColor(_ color:UIColor) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r*r*0.7, green: g*g*0.7, blue: b*b*0.7, alpha: a)   // 同类颜色加深一些
    }
    fileprivate func getHighlightColor(_ state:UITextBoxHighlightState) -> UIColor {
        switch state {
        case .wrong:        return wrongColor
        case .warning:      return warningColor
        case .validator:    return validatorColor
        default:            return self.isFirstResponder ? highlightColor : self.backgroundColor ?? UIColor.white
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}

extension UIColor {
    convenience init(number:UInt32) {
        let b = CGFloat(number & 0xFF) / 255
        let g = CGFloat((number >> 8) & 0xFF) / 255
        let r = CGFloat((number >> 16) & 0xFF) / 255
        let a = number > 0xFFFFFF ? CGFloat((number >> 24) & 0xFF) / 255 : 1.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    convenience init?(hex:String) {
        let regular:NSRegularExpression
        do {
            regular = try NSRegularExpression(pattern: "(#?|0x)[0-9a-fA-F]{2,}", options: NSRegularExpression.Options.caseInsensitive)
        } catch { return nil }
        
        let length = hex.characters.distance(from: hex.startIndex, to: hex.endIndex)
        guard let result = regular.firstMatch(in: hex, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, length)) else {
            print("error: hex isn't color hex value!")
            return nil
        }
        
        let start = hex.characters.index(hex.startIndex, offsetBy: result.rangeAt(1).length + result.rangeAt(1).location)
        let end = hex.characters.index(hex.startIndex, offsetBy: result.range.length + result.range.location)
        let number = strtoul(hex[start..<end], nil, 16)
        let b = CGFloat((number >>  0) & 0xFF) / 255
        let g = CGFloat((number >>  8) & 0xFF) / 255
        let r = CGFloat((number >> 16) & 0xFF) / 255
        let a = number > 0xFFFFFF ? CGFloat((number >> 24) & 0xFF) / 255 : 1.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
