//
//  RegTableViewController.swift
//  CloudIM
//
//  Created by 田子瑶 on 16/8/26.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit
import AJWValidator
import RESideMenu

class RegTableViewController: UITableViewController, RESideMenuDelegate{
    
    @IBOutlet var requiredFields: [UITextField]!
    @IBOutlet weak var userNameInput: UITextBox!
    @IBOutlet weak var passwordInput: UITextBox!
    @IBOutlet weak var emailInput: UITextBox!
    @IBOutlet weak var regionInput: UITextField!
    @IBOutlet weak var questionInput: UITextField!
    @IBOutlet weak var answerInput: UITextField!
    
    var (userOK, passOK, mailOK) = (false, false, false)
    var submitBtn: UIBarButtonItem!
    
    
    //MARK: 检查必填项
    func checkRequiredField() {
        
        for textField in requiredFields {
            if textField.text?.isEmpty == true {
                self.noticeError("必选项有空值", autoClear: true, autoClearTime: 2)
                return
            }
        }
        
        //MARK: 正则表达式和谓词匹配
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        guard predicate.evaluateWithObject(emailInput.text) else {
            self.noticeError("邮箱格式错误", autoClear: true, autoClearTime: 2)
            return
        }
    }
    
    func submitUserInfo() {
        
        //MARK: 转动菊花/载入提示
        self.pleaseWait()
        //MARK: 建立用户信息
        let url = NSURL(string: "http://123.206.27.127/timi/login.php")
        let userInfo = "username=\(userNameInput.text!)&password=\(passwordInput.text!)&useremail=\(emailInput.text!)"
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = userInfo.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, resp, error) in
            let result = (String(data: data!, encoding: NSUTF8StringEncoding))
            if result == "注册成功" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.clearAllNotice()
                    self.noticeSuccess(result!, autoClear: true, autoClearTime: 2)
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
                    
                    //MainView().title.text = self.userNameInput.text!
                    self.navigationController?.presentViewController(sideMenu, animated: true, completion: nil)
                })
            }
            else if result == "用户名已存在" {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        self.title = "注册用户"
        
        submitBtn = UIBarButtonItem(title: "提交",
                                    style: .Done,
                                    target: self,
                                    action: #selector(RegTableViewController.submitUserInfo))
        
        submitBtn.enabled = false
        self.navigationItem.rightBarButtonItem = submitBtn
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegTableViewController.handleTap))
        self.view.addGestureRecognizer(tap)
        
        //        checkInputLength(userNameInput)
        //        checkInputLength(passwordInput)
        
        checkInput(userNameInput, type: "user")
        checkInput(passwordInput, type: "password")
        checkInput(emailInput, type: "email")
        
        //        let checkEmailInput = AJWValidator(type: .String)
        //        checkEmailInput.addValidationToEnsureValidEmailWithInvalidMessage("邮箱格式有误")
        //        emailInput.ajw_attachValidator(checkEmailInput)
        //        checkEmailInput.validatorStateChangedHandler = { state in
        //            switch state {
        //            case .ValidationStateValid:
        //                self.emailInput.highlightState = UITextBoxHighlightState.Default
        //            default:
        //                let error = checkEmailInput.errorMessages.first as! String
        //                self.emailInput.highlightState = UITextBoxHighlightState.Wrong(error)
        //            }
        //        }
        
        //        let rightLabel = UILabel(frame: CGRectMake(0, 0, 50, 30))
        //        userNameInput.rightView = rightLabel
        //        userNameInput.rightViewMode = .WhileEditing
    }
    
    func checkInput(textInput: UITextBox, type: String) {
        
        let check = AJWValidator(type: .String)
        
        if type == "user" || type == "password" {
            check.addValidationToEnsureMinimumLength(3, invalidMessage: "至少3个字符")
            check.addValidationToEnsureMaximumLength(10, invalidMessage: "最多10个字符")
        }
        else if type == "email" {
            check.addValidationToEnsureValidEmailWithInvalidMessage("邮箱格式有误")
        }
        
        textInput.ajw_attachValidator(check)
        check.validatorStateChangedHandler = { state in
            
            switch state {
            case .ValidationStateValid:
                textInput.highlightState = UITextBoxHighlightState.Default
                self.checkResult(type, state: true)
            default:
                let error = check.errorMessages.first as! String
                textInput.highlightState = UITextBoxHighlightState.Wrong(error)
                self.checkResult(type, state: false)
            }
            //MARK: 验证提交按钮的有效性
            self.submitBtn.enabled = self.mailOK && self.passOK && self.userOK
            
            /**
            print("\(self.mailOK) \(self.passOK) \(self.userOK)")
            if self.mailOK && self.passOK && self.userOK {
                print("ok")
                self.submitBtn.enabled = true
            }
            else {
                self.submitBtn.enabled = false
            }
            */
        }
    }
    
    func checkResult(type: String, state: Bool) {
        if type == "user" {
            self.userOK = state
        }
        else if type == "password" {
            self.passOK = state
        }
        else if type == "email" {
            self.mailOK = state
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
