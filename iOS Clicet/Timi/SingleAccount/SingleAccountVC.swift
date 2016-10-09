//
//  SingleAccountVC.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

public let accountModelPath = "DatabaseDoc/AccountModel.db"

protocol SubViewProtocol{
    func clickManageBtn(_ sender:AnyObject!)
    func clickMidAddBtn(_ sender:AnyObject!)
    func presentVC(_ VC:UIViewController, animated:Bool, completion:(()->Void)?)
}

class SingleAccountVC: UIViewController{
    
    //MARK: - properties (private)
    fileprivate var singleAccountModel:SingleAccountModel
    fileprivate var pieChartModel:PieChartModel!
    fileprivate var pieChartView:PieChartView!
    fileprivate var mainView:SingleAccountView!
    fileprivate var lineChartView:LineChartView!
    fileprivate var budgetView:BudgetView!
    
    //MARK: - init
    init(model:SingleAccountModel){
        self.singleAccountModel = model
        super.init(nibName: nil, bundle: nil)
        self.pieChartModel = PieChartModel(dbName: singleAccountModel.initDBName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SingleAccountVC.reloadDataAndViews), name: NSNotification.Name(rawValue: "ChangeDataSource"), object: nil)
        self.view.backgroundColor = UIColor.white
        
        //初始化界面
        setupMainView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - operation (internal)
    func reloadDataAndViews(){
        //更新数据和界面
        singleAccountModel.setAccountBookDataInModel()
        mainView.reloadViews()
        update(mainView)
        //print("reloadDataAndViews")
    }
    
    //MARK: - setup views (private)
    fileprivate func setupMainView(){
        let bgScrollView = setupBgScrollView(self.view.bounds)
        bgScrollView.delaysContentTouches = false
        
        mainView = setupSingleAccountView(self.view.bounds)
        pieChartView = setupPieChartView(CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        lineChartView = setupLineView(CGRect(x: self.view.bounds.width * 2, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        budgetView = setupBudgetView(CGRect(x: self.view.bounds.width * 3, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        bgScrollView.addSubview(mainView)
        bgScrollView.addSubview(pieChartView)
        bgScrollView.addSubview(lineChartView)
        bgScrollView.addSubview(budgetView)
        self.view.addSubview(bgScrollView)
    }
    fileprivate func setupBgScrollView(_ frame:CGRect)->UIScrollView{
        let bgScrollView = BgScrollView(frame: frame)
        bgScrollView.contentSize = CGSize(width: self.view.bounds.width * 4, height: self.view.bounds.height)
        bgScrollView.bounces = false
        bgScrollView.isPagingEnabled = true
        bgScrollView.showsHorizontalScrollIndicator = false
        return bgScrollView
    }
    fileprivate func setupSingleAccountView(_ frame:CGRect)->SingleAccountView{
        let singleAccountView = SingleAccountView(frame: frame, delegate:self)
        //标题、收入和支出
        singleAccountView.costText = String(format: "%.2f", singleAccountModel.totalCost)
        singleAccountView.incomeText = String(format: "%.2f", singleAccountModel.totalIncome)
        
        return singleAccountView
    }
    
    fileprivate func setupPieChartView(_ frame:CGRect) -> PieChartView{
        
        let pieChartView = PieChartView(frame: frame, layerData: pieChartModel.rotateLayerDataArray, delegate:self, dataSource:self)
        pieChartView.reloadPieChartViewData(nil, year: pieChartModel.yearArray[0], cost: pieChartModel.monthTotalMoney[0], income: nil)
        self.pieChartView = pieChartView
        return pieChartView
    }
    fileprivate func setupLineView(_ frame:CGRect)->LineChartView{
        let lineView = LineChartView(frame: frame, infoDataItem: pieChartModel.lineChartInfoArray, pointDataItem: pieChartModel.lineChartMoneyArray,  delegate: self, dataSource: self, tableViewDelegate: self)
        lineView.reloadLineChartViewData(nil, pointDataItem: nil, year:pieChartModel.yearArray[1], cost: pieChartModel.monthTotalMoney[1], income: nil)
        return lineView
    }
    fileprivate func setupBudgetView(_ frame:CGRect)->BudgetView{
        let tmpBudgetView = BudgetView(frame: frame, data: pieChartModel.budgetModelData)
        tmpBudgetView.delegate = self
        return tmpBudgetView
    }
    
    func update(_ singleAccountView: SingleAccountView) {
        
        singleAccountView.costText = String(format: "%.2f", singleAccountModel.totalCost)
        singleAccountView.incomeText = String(format: "%.2f", singleAccountModel.totalIncome)
        //print(singleAccountModel.totalCost)
        //print(singleAccountModel.totalIncome)
    }
}

extension SingleAccountVC: AKPickerViewDataSource, AKPickerViewDelegate{
    
    // MARK: - AKPickerViewDataSource
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        var count = 0
        if pickerView.superview?.isKind(of: PieChartView.self) == true{
            count = self.pieChartModel.pieChartPickerData.count
        }
        else if pickerView.superview?.isKind(of: LineChartView.self) == true{
            count = self.pieChartModel.lineChartPickerData.count
        }
        return count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        var title = ""
        if pickerView.superview?.isKind(of: PieChartView.self) == true{
            title = self.pieChartModel.pieChartPickerData[item]
        }
        else if pickerView.superview?.isKind(of: LineChartView.self) == true{
            title = self.pieChartModel.lineChartPickerData[item]
        }
        return title
    }
    
    // MARK: - AKPickerViewDelegate
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        
        if pickerView.superview?.isKind(of: PieChartView.self) == true{
            pieChartModel.setRotateLayerDataArrayAtIndex(item)
            pieChartView.reloadPieChartViewData(pieChartModel.rotateLayerDataArray, year: pieChartModel.yearArray[item], cost: pieChartModel.monthTotalMoney[item], income: nil)
        }
        else if pickerView.superview?.isKind(of: LineChartView.self) == true{
            pieChartModel.setLineChartTableViewDataAtIndex(item)
            pieChartModel.setLineChartInfoArrayAtIndex(item)
            
            lineChartView.reloadLineChartViewData(pieChartModel.lineChartInfoArray, pointDataItem: pieChartModel.lineChartMoneyArray, year:pieChartModel.yearArray[item + 1], cost: pieChartModel.monthTotalMoney[item + 1], income: nil)
            
        }
    }
}

//MARK: - SubViewProtocol
extension SingleAccountVC: SubViewProtocol{
    func clickManageBtn(_ sender:AnyObject!){
        self.presentLeftMenuViewController(sender)
        
        print("clickManageBtn")
//        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
//        let loginVC = storyBoard.instantiateViewControllerWithIdentifier("Login")
//        print(self.navigationController)
//        self.navigationController?.presentViewController(loginVC, animated: true, completion: nil)
        
        
    }
    func clickMidAddBtn(_ sender:AnyObject!){
        let chooseItemVC = ChooseItemVC()
        chooseItemVC.dissmissCallback = {(item) in
            AccoutDB.insertData(self.singleAccountModel.initDBName, item:item)
        }
        self.present(chooseItemVC, animated: true, completion: nil)
    }
    func presentVC(_ VC: UIViewController, animated: Bool, completion: (() -> Void)?) {
        self.present(VC, animated: animated, completion: completion)
    }
}

extension SingleAccountVC:BudgetViewDelegate{
    func pressSettingBtnWithBudgetView(_ budgetView: BudgetView) {
        
    }
}

extension SingleAccountVC:UITableViewDataSource, UITableViewDelegate{
    //MARK: - tableview delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 0
        if tableView.superview?.isKind(of: SingleAccountView.self) == true {
            height = CGFloat(80)
        }
        else if tableView.superview?.isKind(of: LineChartView.self) == true {
            height = CGFloat(60)
        }
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    //MARK: - tableview datasource
    func itemFromDataSourceWith(_ indexPath:IndexPath) -> AccountItem{
        if (indexPath as NSIndexPath).row < singleAccountModel.itemAccounts.count{
            return singleAccountModel.itemAccounts[(indexPath as NSIndexPath).row]
        }
        return AccountItem()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView.superview?.isKind(of: SingleAccountView.self) == true {
            count = singleAccountModel.itemAccounts.count
            tableView.tableViewDisplayWithMsg("新账本", ifNecessaryForRowCount: count)
        }
        else if tableView.superview?.isKind(of: LineChartView.self) == true {
            count = pieChartModel.lineChartTableViewData.count
            tableView.tableViewDisplayWithMsg("您本月没有记录", ifNecessaryForRowCount: count)
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.superview?.isKind(of: SingleAccountView.self) == true {
            let rowAmount = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)
            let item = itemFromDataSourceWith(indexPath)
            //print(item)
            
            var identify = "OutComeAccountCell"
            
            if item.iconTitle == "工作" || item.iconTitle == "奖金" || item.iconTitle == "理财" {
                identify = "InComeAccountCell"
            }
            else {
                identify = "OutComeAccountCell"
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath) as! AccountCell

            cell.selectionStyle = .none
            cell.presentVCBlock = {[weak self] in
                if let strongSelf = self{
                    let model = ChooseItemModel()
                    let item = AccoutDB.selectDataWithID(strongSelf.singleAccountModel.initDBName, id: item.ID)
                    model.mode = "edit"
                    model.dataBaseId = item.ID
                    model.costBarMoney = item.money
                    model.costBarTitle = item.iconTitle
                    model.costBarIconName = item.iconName
                    model.costBarTime = TimeInterval(item.date)
                    model.topBarRemark = item.remark
                    model.topBarPhotoName = item.photo
                    
                    let editChooseItemVC = ChooseItemVC(model: model)
                    editChooseItemVC.dissmissCallback = {(item) in
                        
                        AccoutDB.updateData(strongSelf.singleAccountModel.initDBName, item:item)
                    }
                    strongSelf.present(editChooseItemVC, animated: true, completion: nil)
                }
                
            }
            cell.deleteCell = {[weak self] in
                if let strongSelf = self{
                    let alertView = UIAlertController(title: "删除账目", message: "您确定要删除吗？", preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    alertView.addAction(UIAlertAction(title: "确定", style: .default){(action) in
                        AccoutDB.deleteDataWith(strongSelf.singleAccountModel.initDBName, ID: item.ID)
                        strongSelf.reloadDataAndViews()
                        })
                    strongSelf.present(alertView, animated: true, completion: nil)
                }
            }
            
            cell.botmLine.isHidden = false
            cell.dayIndicator.isHidden = true
            
            let imagePath = String.createFilePathInDocumentWith(item.photo) ?? ""
            cell.cellID = item.ID
            cell.iconTitle.text = item.iconTitle
            cell.icon.setImage(UIImage(named: item.iconName), for: UIControlState())
            cell.itemCost.text = item.money
            cell.remark.text = item.remark
            cell.date.text = item.dateString
            
            //图片
            if let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)){
                cell.photoView.image = UIImage(data: data)
            }
            //日期指示器
            if item.dayCost != "" && item.dateString != ""{
                cell.dayIndicator.isHidden = false
            }
            
            //最后一个去掉尾巴
            if (indexPath as NSIndexPath).row == rowAmount - 1{
                cell.botmLine.isHidden = true
            }
            
            return cell
        }
        else if tableView.superview?.isKind(of: LineChartView.self) == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartTableViewCell", for: indexPath) as! LineChartTableViewCell
            
            let item = pieChartModel.lineChartTableViewData[(indexPath as NSIndexPath).row]
            cell.money.text = item.money
            cell.title.text = item.title
            cell.icon.image = UIImage(named: item.icon)
            cell.layoutIfNeeded()
            
            var widthScale = Float(item.money)! / Float(pieChartModel.lineChartTableViewData[0].money)!
            widthScale = widthScale > 0.01 ? widthScale :0.01
            cell.constraintBtwnPercentageAndMoney.constant = cell.percentage.width - cell.percentage.width * CGFloat(widthScale) + CGFloat(23.0)
            cell.percentage.backgroundColor = UIColor(hue: CGFloat(widthScale), saturation: 0.4, brightness: 0.8, alpha: 1.0)
            return cell
        }
        return UITableViewCell()
    }
}
