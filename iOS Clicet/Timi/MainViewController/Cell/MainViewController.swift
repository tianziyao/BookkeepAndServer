//
//  MainViewController.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

private let customAccountName = "DatabaseDoc/AccountModel"

class MainViewController: UIViewController {
    
    var mainVCModel:MainVCModel!
    var mainView:MainView!
    var customAlertView:CustomAlertView!
    var operateAccountBook:OperateAccountBookView!
    
    init(model: MainVCModel){
        self.mainVCModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //建立主页面
        setupMainView()
        setupCustomAlertView()
        setupOperateAccountBookView()
        mainButtonAddTap()
    }
    override func viewWillAppear(_ animated: Bool) {
        //更新数据
        mainVCModel.reloadModelData()
        //更新页面
        mainView.reloadCollectionView()
    }
    
    func mainButtonAddTap() {
        mainView.icon.addTarget(self, action: #selector(MainViewController.presentToLoginVC), for: .touchUpInside)
        mainView.upload.addTarget(self, action: #selector(MainViewController.upload), for: .touchUpInside)
    }
    
    ///////////////////////////////////////////////////////////////
    func upload() {
        //从数据库中取出所有数据
        self.pleaseWait()
        let itemAccounts = AccoutDB.selectDataOrderByDate("DatabaseDoc/AccountModel.db")
        var datas: Array = [[String:AnyObject]]()
        for sourceItem in itemAccounts {
            let data = sourceItem.keyValues
            datas.append(data!)
        }
        
        let json = try? JSONSerialization.data(withJSONObject: datas, options: .prettyPrinted)
        print("-----------\n")
        
        let url = URL(string: "http://123.206.27.127/timi/upload.php")
        //let url = NSURL(string: "http://localhost:8888/i/timi/upload.php")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, resp, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                let str = String(data: data!, encoding: String.Encoding.utf8)
                if str == "写入成功" {
                    DispatchQueue.main.async(execute: {
                        self.clearAllNotice()
                        self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 2)
                    })
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.clearAllNotice()
                        self.noticeSuccess("上传失败", autoClear: true, autoClearTime: 2)
                    })
                }
            }
        }) 
        
        task.resume()
    }
    
    func presentToLoginVC() {
        print("presentToLoginVC")
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "Login")
        print(self.navigationController)
        self.navigationController?.present(loginVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - longPress
    func longPressAction(_ sender:UILongPressGestureRecognizer){
        let point = sender.location(in: mainView.accountBookBtnView)
        let indexPath = mainView.accountBookBtnView.indexPathForItem(at: point)
        if let indexPath = indexPath{
            let cellCount = mainView.accountBookBtnView.numberOfItems(inSection: (indexPath as NSIndexPath).section) 
            let cell = mainView.accountBookBtnView.cellForItem(at: indexPath) as! AccountBookCell
            //最后一个cell是加号，不用做长按处理
            if (indexPath as NSIndexPath).row < cellCount - 1{
                if sender.state == .began{
                    let item = mainVCModel.getItemInfoAtIndex((indexPath as NSIndexPath).row)
                    let title = item?.btnTitle ?? ""
                    cell.highlightedViewAlpha = AccountCellPressState.longPress.rawValue
                    //弹出修改的按钮
                    operateAccountBook.showBtnAnimation()
                    operateAccountBook.cancelBlock = {[weak self] in
                        if let strongSelf = self{
                            strongSelf.operateAccountBook.hideBtnAnimation()
                            cell.highlightedView.alpha = AccountCellPressState.normal.rawValue
                        }
                    }
                    operateAccountBook.deleteBlock = {[weak self] in
                        if let strongSelf = self{
                            let alert = UIAlertController(title: "删除\(title)", message: "将会删除所有数据，不会恢复", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {(action) in
                                //删除数据源
                                strongSelf.mainVCModel.removeBookItemAtIndex((indexPath as NSIndexPath).row)
                                //执行删除操作
                                strongSelf.mainView.accountBookBtnView.deleteItems(at: [indexPath])
                                strongSelf.operateAccountBook.hideBtnAnimation()
                                cell.highlightedView.alpha = AccountCellPressState.normal.rawValue
                            }))
                            strongSelf.present(alert, animated: true, completion: nil)
                        }
                    }
                    operateAccountBook.editBlock = {[weak self] in
                        if let strongSelf = self{
                            strongSelf.editAccountBook(item, indexPath:indexPath){ (title, imageName) in
                                
                                if let editItem = strongSelf.mainVCModel.getItemInfoAtIndex((indexPath as NSIndexPath).row){
                                    editItem.btnTitle = title
                                    editItem.backgrountImageName = imageName
                                    strongSelf.mainVCModel.updateBookItem(editItem, atIndex:(indexPath as NSIndexPath).row)
                                    strongSelf.mainView.accountBookBtnView.reloadItems(at: [indexPath])
                                    strongSelf.operateAccountBook.hideBtnAnimation()
                                }
                                //退出alertview
                                strongSelf.customAlertView.removeFromSuperview()
                            }
                            cell.highlightedView.alpha = AccountCellPressState.normal.rawValue
                        }
                        
                    }
                }
            }
        }
    }
    
    func editAccountBook(_ item:AccountBookBtn?, indexPath:IndexPath, sureBlock:@escaping (String, String)->Void){
        customAlertView.title = item?.btnTitle ?? ""
        customAlertView.initChooseImage = item?.backgrountImageName ?? "book_cover_0"
        customAlertView.cancelBlock = {[weak self] in
            if let strongSelf = self{
                strongSelf.customAlertView.removeFromSuperview()
            }
        }
        customAlertView.sureBlock = sureBlock
        UIApplication.shared.keyWindow?.addSubview(self.customAlertView)
    }
    
    //MARK: - setup views(private)
    //建立主页面
    fileprivate func setupMainView(){
        let mainViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let mainView = MainView(frame: mainViewFrame, delegate:self)
        self.mainView = mainView
        self.view.addSubview(mainView)
    }
    fileprivate func setupCustomAlertView(){
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let customAlertView = CustomAlertView(frame: frame)
        self.customAlertView = customAlertView
    }
    fileprivate func setupOperateAccountBookView(){
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let operateAccountBook = OperateAccountBookView(frame: frame)
        self.operateAccountBook = operateAccountBook
        self.view.addSubview(operateAccountBook)
    }
}
//MARK: - UICollectionViewDelegate
extension MainViewController:UICollectionViewDelegate{
    //MARK: - selected cell
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! AccountBookCell
        let cellCount = collectionView.numberOfItems(inSection: (indexPath as NSIndexPath).section)
        if (indexPath as NSIndexPath).row == cellCount - 1{
            return false
        }
        else{
            if cell.highlightedViewAlpha < 0.59{
                return true
            }
            else{
                return false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainVCModel.showFlagWithIndex((indexPath as NSIndexPath).row)
        mainView.reloadCollectionView()
    }
    //MARK: - highlighted cell
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AccountBookCell
        cell.highlightedViewAlpha = AccountCellPressState.highlighted.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AccountBookCell
        //浮点数没法精确，所以只能用小于
        if cell.highlightedViewAlpha <= AccountCellPressState.highlighted.rawValue + 0.1{
            cell.highlightedViewAlpha = AccountCellPressState.normal.rawValue
            
            let cellCount = collectionView.numberOfItems(inSection: (indexPath as NSIndexPath).section)
            if (indexPath as NSIndexPath).row == cellCount - 1{
                
                editAccountBook(nil, indexPath: indexPath){[weak self](title, imageName) in
                    if let strongSelf = self{
                        //建一个数据库
                        let currentTime = Int(Date().timeIntervalSince1970)
                        let dbName = customAccountName + "\(currentTime)" + ".db"
                        let item = AccountBookBtn(title: title, count: "0笔", image: imageName, flag: false, dbName: dbName)
                        //插入账本
                        strongSelf.mainVCModel.addBookItemByAppend(item)
                        strongSelf.mainView.accountBookBtnView.insertItems(at: [indexPath])
                        //退出alertview
                        strongSelf.customAlertView.removeFromSuperview()
                    }
                }
            }
            else{
                //切换到contentView
                if let item = mainVCModel.getItemInfoAtIndex((indexPath as NSIndexPath).row){
                    let singleAccountModel = SingleAccountModel(initDBName: item.dataBaseName, accountTitle: item.btnTitle)
                    let tmpSingleAccountVC = SingleAccountVC(model: singleAccountModel)
                    self.sideMenuViewController.setContentViewController(tmpSingleAccountVC, animated: true)
                    self.sideMenuViewController.hideViewController()
                }
            }
        }
    }
}
//MARK: - UICollectionViewDataSource
extension MainViewController:UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainVCModel.accountsBtns.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountBookBtnCell", for: indexPath) as! AccountBookCell
        let cellData = mainVCModel.accountsBtns[(indexPath as NSIndexPath).row]
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.longPressAction(_:)))
        longPress.cancelsTouchesInView = false
        cell.addGestureRecognizer(longPress)
        cell.accountTitle.text = cellData.btnTitle
        cell.accountCounts.text = cellData.accountCount
        cell.accountBackImage.image = UIImage(named: cellData.backgrountImageName)
        cell.selectedFlag.alpha = cellData.selectedFlag ? 1 : 0
        
        return cell
    }
    
}
