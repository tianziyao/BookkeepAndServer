//
//  LoginViewController.swift
//  CloudIM
//
//  Created by 田子瑶 on 16/8/26.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit
import JSAnimatedImagesView
import RESideMenu

//和StrokeImageView二选一
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
    
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue>0)
        }
    }
    
}

class LoginViewController: UIViewController, JSAnimatedImagesViewDataSource, RESideMenuDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var backgroudView: JSAnimatedImagesView!
    
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func loginBtnDidClick(sender: AnyObject) {
      
        let url = NSURL(string: "http://123.206.27.127/timi/signin.php")
        let request = NSMutableURLRequest(URL: url!)
        let userInfo = "username=\(userNameInput.text!)&password=\(passwordInput.text!)"
        request.HTTPMethod = "POST"
        request.HTTPBody = userInfo.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, resp, error) in
            let result = (String(data: data!, encoding: NSUTF8StringEncoding))
            if result == "登录成功" {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.clearAllNotice()
                    self.noticeSuccess(result!, autoClear: true, autoClearTime: 2)
                    let singleAccountModel = SingleAccountModel(initDBName: "DatabaseDoc/AccountModel.db", accountTitle: "日常账本")
                    let mainVCModel = MainVCModel()
                    let leftMenuVC = MainViewController(model: mainVCModel)
                    let homeVC = SingleAccountVC(model: singleAccountModel)
                    let sideMenu = RESideMenu.init(contentViewController: homeVC, leftMenuViewController: leftMenuVC, rightMenuViewController: nil)
                    let ScreenWithRatio = UIScreen.mainScreen().bounds.width / 375
                    sideMenu.delegate = self
                    sideMenu.contentViewInPortraitOffsetCenterX = 150 * ScreenWithRatio
                    sideMenu.contentViewShadowEnabled = true
                    sideMenu.contentViewShadowOffset = CGSize(width: -2, height: -2)
                    sideMenu.contentViewShadowColor = UIColor.blackColor()
                    sideMenu.scaleContentView = false
                    sideMenu.scaleMenuView = false
                    sideMenu.fadeMenuView = false
                    self.navigationController?.presentViewController(sideMenu, animated: true, completion: nil)
                })
            }
            else if result == "用户名或密码错误" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.clearAllNotice()
                    self.noticeError(result!, autoClear: true, autoClearTime: 2)
                })
            }
            else {
                print(error?.localizedDescription)
            }

        }
        task.resume()
    }
    
    
    @IBAction func signoutBtnDidClick(sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor.darkGrayColor().CGColor
//        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
//        self.view.addGestureRecognizer(tap)
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5) {
            self.loginStackView.axis = .Vertical
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.backgroudView.dataSource = self
    }
    
    
    func animatedImagesNumberOfImages(animatedImagesView: JSAnimatedImagesView!) -> UInt {
        return 3
    }
    
    func animatedImagesView(animatedImagesView: JSAnimatedImagesView!, imageAtIndex index: UInt) -> UIImage! {
        return UIImage(named: "wallpaper\(index + 1)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
