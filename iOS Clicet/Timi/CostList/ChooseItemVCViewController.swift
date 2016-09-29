//
//  ChooseItemVCViewController.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let AccountPhoto = "AccountPhoto"

protocol ComputeBoardProtocol{
    func onPressBack()
    func clickTime()
    func clickRemark()
    func clickPhoto()
}
protocol ChooseItemProtocol{
    func setCostBarIconAndTitle(_ icon:String, title:String)
}

protocol TopBarProtocol{
    func clickBack(_ sender:AnyObject!)
}

private let myContent = 0

class ChooseItemVC: UIViewController, ChooseItemProtocol {
    
    let ScreenWidth = UIScreen.main.bounds.width
    let ScreenHeight = UIScreen.main.bounds.height
    
    let ComputeBoardHeight =  UIScreen.main.bounds.height/2 - 20 + 72
    
    let TopBarHeight: CGFloat = 44.0
    var computedBar:ComputeBoardView?
    var topBar:TopBarView?
    var datePicker:UIView?
    
    var dissmissCallback:((AccountItem)->Void)?
    
    //dataModel
    var chooseItemModel:ChooseItemModel
    
    init(model:ChooseItemModel){
        chooseItemModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(){
        self.init(model: ChooseItemModel())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit{
        chooseItemModel.removeObserver(self, forKeyPath: "costBarTime")
        chooseItemModel.removeObserver(self, forKeyPath: "costBarIconName")
        chooseItemModel.removeObserver(self, forKeyPath: "costBarTitle")
        chooseItemModel.removeObserver(self, forKeyPath: "costBarMoney")
        chooseItemModel.removeObserver(self, forKeyPath: "topBarRemark")
        chooseItemModel.removeObserver(self, forKeyPath: "topBarPhotoName")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        chooseItemModel.addObserver(self, forKeyPath: "costBarTime", options: [.new, .old], context: nil)
        chooseItemModel.addObserver(self, forKeyPath: "costBarIconName", options: [.new, .old], context: nil)
        chooseItemModel.addObserver(self, forKeyPath: "costBarTitle", options: [.new, .old], context: nil)
        chooseItemModel.addObserver(self, forKeyPath: "costBarMoney", options: [.new, .old], context: nil)
        chooseItemModel.addObserver(self, forKeyPath: "topBarRemark", options: [.new, .old], context: nil)
        chooseItemModel.addObserver(self, forKeyPath: "topBarPhotoName", options: [.new, .old], context: nil)
        //创建顶部栏
        setupTopBar()
        //创建图标项
        setupItem()
        //消费金额和计算面板栏
        setupComputeBoard()
        //时间选择器
        setupDatePicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //创建顶部栏
    func setupTopBar(){
        //底部栏
        let topBar = TopBarView(frame: CGRect(x: 0, y: 20, width: ScreenWidth, height: TopBarHeight))
        if chooseItemModel.topBarPhotoName != ""{
            topBar.topBarInitPhoto = UIImage.generateImageWithFileName(chooseItemModel.topBarPhotoName)
        }
        topBar.delegate = self
        self.topBar = topBar
        //添加到主view上
        self.view.addSubview(topBar)
    }
    
    //创建图标项
    func setupItem(){
        let ItemBarHeight = ScreenHeight - 20 - TopBarHeight - ComputeBoardHeight
        let itemBar = ItemBarView(frame: CGRect(x: 0, y: 20 + TopBarHeight , width: ScreenWidth, height: ItemBarHeight))
        itemBar.delegate = self
        self.view.addSubview(itemBar)
    }
    
    //创建计算面板
    func setupComputeBoard(){
        //创建计算面板
        let computeBoard = ComputeBoardView(frame: CGRect(x: 0, y: ScreenHeight - ComputeBoardHeight, width: ScreenWidth, height: ComputeBoardHeight))
        computeBoard.delegate = self
        computeBoard.time = chooseItemModel.getCostBarTimeInString()
        computeBoard.icon = UIImage(named: chooseItemModel.costBarIconName)
        computeBoard.title = chooseItemModel.costBarTitle
        computeBoard.money = chooseItemModel.costBarMoney
        //修改model中的金额
        computeBoard.computedResult = {[weak self](float) in
            if let strongSelf = self{
                strongSelf.chooseItemModel.setCostBarMoneyWithFloat(float)
            }
        }
        //点击OK时要执行一系列操作
        computeBoard.pressOK = {[weak self] in
            
            if let strongSelf = self{
                if let money = strongSelf.chooseItemModel.getCostBarMoneyInFloat(){
                    if money < 0.001{
                        strongSelf.computedBar?.shakeCostBarMoney()
                    }
                    else{
                        let item = AccountItem()
                        item.ID = strongSelf.chooseItemModel.dataBaseId
                        item.money = strongSelf.chooseItemModel.costBarMoney
                        item.iconTitle = strongSelf.chooseItemModel.costBarTitle
                        item.iconName = strongSelf.chooseItemModel.costBarIconName
                        item.date = Int(strongSelf.chooseItemModel.costBarTime)
                        item.remark = strongSelf.chooseItemModel.topBarRemark
                        item.photo = strongSelf.chooseItemModel.topBarPhotoName
                        if strongSelf.chooseItemModel.mode == "edit"{
                            if let dissmissCallback = strongSelf.dissmissCallback{
                                dissmissCallback(item)
                            }
                        }
                        else if strongSelf.chooseItemModel.mode == "init" {
                            if let dissmissCallback = strongSelf.dissmissCallback{
                                dissmissCallback(item)
                            }
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangeDataSource"), object: strongSelf)
                        strongSelf.onPressBack()
                    }
                    
                }
                
            }
            
        }
        //点击收入或分支选项也要执行切换操作
        computeBoard.pressIncomeAndCost = {() in }
        computedBar = computeBoard
        //添加到self.view
        self.view.addSubview(computeBoard)
    }
    //时间选择器
    func setupDatePicker(){
        let datePickerView = CustomDatePicker(frame: self.view.frame, date: chooseItemModel.getCostBarTimeInDate(), cancel: nil, sure: nil)
        datePickerView.isHidden = true
        datePickerView.cancelCallback = {[weak datePickerView] in
            if let strongDatePickerView = datePickerView{
                strongDatePickerView.isHidden = !strongDatePickerView.isHidden
            }
        }
        datePickerView.sureCallback = {[weak self](date)-> () in
            if let strongSelf = self{
                //new change
                strongSelf.chooseItemModel.setCostBarTimeWithDate(date)
            }
            
        }
        datePicker = datePickerView
        self.view.addSubview(datePickerView)
    }
    
    func setCostBarIconAndTitle(_ icon: String, title: String) {
        chooseItemModel.costBarIconName = icon
        chooseItemModel.costBarTitle = title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath ?? "" {
        case "costBarTime":
            computedBar?.time = chooseItemModel.getCostBarTimeInString()
            topBar?.topBarChangeTime?.setTitleColor(UIColor.orange, for: UIControlState())
        case "costBarIconName":
            computedBar?.icon = UIImage(named:chooseItemModel.costBarIconName)
        case "costBarTitle":
            computedBar?.title = chooseItemModel.costBarTitle
        case "costBarMoney":
            computedBar?.money = chooseItemModel.costBarMoney
        case "topBarRemark":
            if let newValue = change?[NSKeyValueChangeKey.newKey]{
                if newValue as! String == ""{
                    topBar?.topBarAddRemark?.setTitleColor(UIColor.black, for: UIControlState())
                }
                else{
                    topBar?.topBarAddRemark?.setTitleColor(UIColor.orange, for: UIControlState())
                }
            }
        case "topBarPhotoName":
            if let newValue = change?[NSKeyValueChangeKey.newKey]{
                let value = newValue as! String
                if value == ""{
                    topBar?.topBarTakePhoto?.isHidden = false
                    topBar?.topBarTakePhotoImage?.isHidden = true
                }
                else{
                    if let image = UIImage.generateImageWithFileName(value){
                        topBar?.topBarTakePhotoImage?.setImage(image, for: UIControlState())
                        topBar?.topBarTakePhoto?.isHidden = true
                        topBar?.topBarTakePhotoImage?.isHidden = false
                    }
                }
            }
        default:
            print("error keypath")
            
        }
    }
}

extension ChooseItemVC: TopBarProtocol{
    func clickBack(_ sender:AnyObject!){
        self.dismiss(animated: true, completion: nil)
    }
    func clickTime(){
        self.datePicker?.isHidden = !self.datePicker!.isHidden
    }
    func clickRemark() {
        let limitInputVC = LimitInputVC()
        limitInputVC.initVCDate = chooseItemModel.getCostBarTimeInString()
        limitInputVC.text = chooseItemModel.topBarRemark
        limitInputVC.completeInput = {(text) in self.chooseItemModel.topBarRemark = text}
        self.present(limitInputVC, animated: true, completion: nil)
    }
    func clickPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}
extension ChooseItemVC: ComputeBoardProtocol{
    func onPressBack() {
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension ChooseItemVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //转为二进制，压缩
        let imageData = UIImage.cropAndCompressImage(image, scale: 0.5, compressionQualiy: 0.7)
        //生成文件名
        let imageName = "AccountPhoto/image-" + String(Date().timeIntervalSince1970)
        //生成路径
        let imagePath = String.createFilePathInDocumentWith(imageName) ?? ""
        //写入文件
        if ((try? imageData?.write(to: URL(fileURLWithPath: imagePath), options: [])) != nil) == true {
            chooseItemModel.topBarPhotoName = imageName
        }
        else{
            print("write AccountImage failed!")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

