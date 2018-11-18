//
//  ViewController.swift
//  Stand
//
//  Created by HikikomoriMaster on 2018/11/08.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import UIKit
import HealthKit

struct StandData {
    let start: Int
    let stood: Int
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startDate: DatePickerInput!
    @IBOutlet weak var endDate: DatePickerInput!
    @IBOutlet weak var getDataButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var dateOrder: [String] = []
    var dataSource: [String : [StandData]] = [:]
    let formatter: DateFormatter = DateFormatter()
    let healthStore: HKHealthStore = HKHealthStore()
    let objectTypes: Set<HKObjectType> = [
        HKObjectType.activitySummaryType(),
        HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorization()
        
        let textColor = BlueColor.getColor(tone: .pg)
        startDateLabel.textColor = textColor
        arrowLabel.textColor = textColor
        endDateLabel.textColor = textColor
        headerView.backgroundColor = BlueColor.getColor(tone: .vd)
        getDataButton.backgroundColor = BlueColor.getColor(tone: .g)
        getDataButton.addTarget(self, action: #selector(getStandCountDetail(_:)), for: UIControl.Event.touchUpInside)
        
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.timeZone = TimeZone.current

        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.register(UINib(nibName: "StandDataTableViewCell", bundle: nil), forCellReuseIdentifier: "StandDataTableViewCell")
    }
    
    // アクセス権の確認画面を表示
    func authorization() {
        let status = healthStore.authorizationStatus(for: HKObjectType.activitySummaryType())
        if status == HKAuthorizationStatus.notDetermined {
            healthStore.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in }
        }
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // UITextFieldDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateKey = dateOrder[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandDataTableViewCell") as! StandDataTableViewCell
        cell.setData(date: dateKey, standData: dataSource[dateKey]!)
        return cell
    }
    
    @objc func getStandCountDetail(_ sender: Any) {
        // 取得したいデータのタイプを生成.
        let categoryType = HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)
        let startDateTarget = formatter.date(from: startDate.getDate())
        let endDateTarget = formatter.date(from: endDate.getDate())
        
        // 開始日が終了日よりも未来の場合はメッセージを表示
        if startDateTarget?.compare(endDateTarget!) == ComparisonResult.orderedDescending {
            showMessage(hasError:true, msg: "StartDate Must Be Earlier Than EndDate.")
            return
        }
        // どちらも未来日の時はメッセージを表示
        if startDateTarget?.compare(Date()) == ComparisonResult.orderedDescending
            && endDateTarget?.compare(Date()) == ComparisonResult.orderedDescending {
            showMessage(hasError:false, msg: "Data Not Found. Future Date is Selected")
            return
        }
        
        // 登録順ソートの設定
        let mySortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let predicate = HKQuery.predicateForSamples(withStart: startDateTarget, end: endDateTarget, options: [])
        let mySampleQuery = HKSampleQuery(sampleType: categoryType!, predicate: predicate, limit: 0, sortDescriptors: [mySortDescriptor]) {(query, results, error ) in

            self.dataSource = [:]
            self.dateOrder = []
            
            if let e = error {
                self.showMessage(hasError: false, msg: e.localizedDescription)
                return
            }
            
            guard (results != nil) && (results?.count)! > 0 else {
                self.showMessage(hasError: false, msg: "Data Not Found.")
                return
            }
            
            results!.forEach({ result in
                let calendar = Calendar.autoupdatingCurrent
                let startDateComponents = calendar.dateComponents([.hour], from: result.startDate)
                let key = self.formatter.string(from: result.startDate)
                let stood = result as! HKCategorySample
                
                let standData = StandData(start: startDateComponents.hour!, stood: stood.value)
                
                if !self.dateOrder.contains(key) {
                    self.dateOrder.append(key)
                }
                
                if self.dataSource[key] != nil {
                    self.dataSource[key]?.append(standData)
                } else {
                    self.dataSource[key] = [standData]
                }
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        healthStore.execute(mySampleQuery)
    }
    
    func showMessage(hasError:Bool, msg: String) {
        if hasError {
            messageLabel.textColor = UIColor.init(hex: "#FF0098")   // Magenta
        } else {
            messageLabel.textColor = BlueColor.getColor(tone: .pg)
        }
        messageLabel.text = msg
        
        dataSource = [:]
        dateOrder = []
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.messageLabel.text = ""
        }
    }
}
