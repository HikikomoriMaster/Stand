//
//  ViewController.swift
//  Stand
//
//  Created by 深石祐太朗 on 2018/11/08.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITabBarDelegate{
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var startDate: DatePickerInput!
    @IBOutlet weak var endDate: DatePickerInput!

    @IBOutlet weak var getDataButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    let healthStore: HKHealthStore = HKHealthStore()
    let objectTypes: Set<HKObjectType> = [HKObjectType.activitySummaryType()]
    var dataSource: [HKActivitySummary] = [HKActivitySummary]()
    let formatter: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        headerView.backgroundColor = BlueColor.getColor(palette: .vd)

        let textColor = BlueColor.getColor(palette: .pg)
        startDateLabel.textColor = textColor
        arrowLabel.textColor = textColor
        endDateLabel.textColor = textColor
        messageLabel.textColor = textColor

        getDataButton.backgroundColor = BlueColor.getColor(palette: .g)
        getDataButton.addTarget(self, action: #selector(getStandCount(_:)), for: UIControl.Event.touchUpInside)

        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        formatter.dateFormat = "yyyy/MM/dd"

        authorization()
    }

    func authorization() {
        // アクセス権の確認画面を表示
        let status = healthStore.authorizationStatus(for: HKObjectType.activitySummaryType())
        if status == HKAuthorizationStatus.notDetermined {
            healthStore.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in }
        }
    }
    
    @objc func getStandCount(_ sender: Any) {
        let calendar = Calendar.autoupdatingCurrent
        var startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate.getDate())
        startDateComponents.calendar = calendar
        var endDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate.getDate())
        endDateComponents.calendar = calendar
        
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            guard let summaries = summaries, summaries.count > 0
                else {
                    // No data returned. Perhaps check for error
                    self.dataSource = [HKActivitySummary]()
                    return
            }
            self.dataSource = summaries
        }
        healthStore.execute(query)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        let date = self.formatter.string(from: data.dateComponents(for: Calendar.current).date!)
        let standUnit = HKUnit.count()
        let count = Int(data.appleStandHours.doubleValue(for: standUnit))

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text  = date
        cell?.detailTextLabel?.text = "\(count)回"

        return cell!
    }
}
