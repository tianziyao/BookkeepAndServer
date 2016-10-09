//
//  LineChartView.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit

class LineChartView: AccountDisplayViewBase {
    
    weak var tableViewDelegate:SingleAccountVC!
    
    fileprivate var monthDataTableView:UITableView!
    fileprivate var lineChartHeight:CGFloat{
        return (bounds.height - 160.0) / 2
    }
    fileprivate var lineChart:LineChartViewComponent!
    fileprivate var pointDataItem:[Float]!
    fileprivate var infoDataItem:[LineChartInfoData]!
    
    //init (internal)
    init(frame:CGRect, infoDataItem:[LineChartInfoData]!, pointDataItem:[Float]!, delegate:AKPickerViewDelegate!, dataSource:AKPickerViewDataSource,tableViewDelegate:SingleAccountVC!){
        self.infoDataItem = infoDataItem
        self.pointDataItem = pointDataItem
        self.tableViewDelegate = tableViewDelegate
        super.init(frame: frame, delegate: delegate, dataSource: dataSource)
        setupViews(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadLineChartViewData(_ infoDataItem:[LineChartInfoData]?, pointDataItem:[Float]?, year:String, cost:String?, income:String?){
        
        if let infoDataItem = infoDataItem{
            lineChart.infoDataItem = infoDataItem
        }
        if let pointDataItem = pointDataItem{
            lineChart.pointDataItem = pointDataItem
        }
        self.setYear(year)
        if let cost = cost{
            self.pieChartTotalCost = cost
        }
        if let income = income{
            self.pieChartTotalIncome = income
        }
        lineChart.setNeedsDisplay()
        monthDataTableView.reloadData()
    }
    
    //MARK: - setup views(private)
    fileprivate func setupViews(_ frame:CGRect){
        setupLineChartView(CGRect(x: 0, y: 180, width: frame.width, height: lineChartHeight - 20))
        setupTableView(CGRect(x: 0, y: lineChartHeight + 160, width: frame.width, height: lineChartHeight))
    }
    
    fileprivate func setupLineChartView(_ frame:CGRect){
        lineChart = LineChartViewComponent(frame: frame, pointDataItem: pointDataItem, infoDataItem: infoDataItem)
        
        let sepLine = UIView(frame: CGRect(x: 0, y: frame.height - 1 + frame.origin.y, width: frame.width, height: 0.5))
        sepLine.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        self.addSubview(lineChart)
        self.addSubview(sepLine)
    }
    
    fileprivate func setupTableView(_ frame:CGRect){
        
        let tableView = UITableView(frame: frame)
        tableView.register(UINib(nibName: "LineChartTableViewCell", bundle: nil), forCellReuseIdentifier: "LineChartTableViewCell")
        tableView.delegate = tableViewDelegate
        tableView.dataSource = tableViewDelegate
        tableView.separatorStyle = .none
        monthDataTableView = tableView
        self.addSubview(tableView)
    }
}
