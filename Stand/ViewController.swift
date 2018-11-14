//
//  ViewController.swift
//  Stand
//
//  Created by 深石祐太朗 on 2018/11/08.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController{
    
    //UIKit
    let keyColor: UIColor = UIColor.hex(string: "#4527A0", alpha: 1.0)
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    

    // HealthKit
    let healthStore = HKHealthStore()
    let objectTypes: Set<HKObjectType> = [
        HKObjectType.activitySummaryType()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // アクセス権の確認画面を表示
        let status = healthStore.authorizationStatus(for: HKObjectType.activitySummaryType())
        if status == HKAuthorizationStatus.notDetermined {
            healthStore.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let start = formatter.date(from: "2018-11-01T11:08:17.098+09:00")
        
        getStandCount(startDate: start!, endDate: Date())
        
        // 日付入力のセットアップ
        textFieldSetup()
    }
    
    func textFieldSetup() {
        let startDateToolBar = UIToolbar()
        startDateToolBar.sizeToFit()
        let startDateToolBarButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(startDateFinishEditing(_:)))
        startDateToolBar.items = [startDateToolBarButton]
        
        startDate.inputAccessoryView = startDateToolBar
        startDate.addTarget(self, action: #selector(startDateTouchUpInside(_:)), for: UIControl.Event.allTouchEvents)
        startDate.addBorderBottom(height: 2.0, color: keyColor)

        let endDateToolBar = UIToolbar()
        endDateToolBar.sizeToFit()
        let endDateToolBarButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(endDateFinishEditing(_:)))
        endDateToolBar.items = [endDateToolBarButton]
        
        endDate.inputAccessoryView = endDateToolBar
        endDate.addTarget(self, action: #selector(endDateTouchUpInside(_:)), for: UIControl.Event.allTouchEvents)
        endDate.addBorderBottom(height: 2.0, color: keyColor)
    }
    
    @objc func startDateTouchUpInside(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(startDatePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
    }

    @objc func startDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        startDate.text = dateFormatter.string(from: sender.date)
    }

    @objc func startDateFinishEditing(_ sender: UITextField){
        startDate.resignFirstResponder()
    }
    
    @objc func endDateTouchUpInside(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.addTarget(self, action: #selector(endDatePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
        sender.inputView = datePickerView
    }

    @objc func endDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        endDate.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func endDateFinishEditing(_ sender: UITextField){
        endDate.resignFirstResponder()
    }
    
    func getStandCount(startDate: Date, endDate: Date) {
       
        let calendar = Calendar.autoupdatingCurrent
        
        var startDateComponents = calendar.dateComponents([.year, .month, .day], from:startDate)
        startDateComponents.calendar = calendar

        var endDateComponents = calendar.dateComponents([.year, .month, .day], from:endDate)
        endDateComponents.calendar = calendar


        let aStandHour =  HKCategoryType.categoryType(forIdentifier: .appleStandHour)
        
        
        let thepredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            //HKQuery.predicateForCategorySamples(with: .greaterThanOrEqualTo, value: 0)
        
        let endDatea: NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        
        let sHourQuery = HKSampleQuery(sampleType: aStandHour!,
                                       predicate: thepredicate,
                                       limit: 100,
                                       sortDescriptors: [endDatea],
                                       resultsHandler: {(query, results, error) in
            
            // 実行後
            if error == nil{
            if let samples = results as? [HKCategorySample]{
                samples.forEach({ data in
                                    var formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy/MM/dd"
                    
                    print(data)
                    
                                })
                
                }
                                        }
        }
            )
        
        
        
        
        // Start the query
        healthStore.execute(sHourQuery)
        
//
//        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
//
//        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
//
//            guard let summaries = summaries, summaries.count > 0
//                else {
//                    // No data returned. Perhaps check for error
//                    return
//            }
//
//            let standUnit = HKUnit.count()
//
//            summaries.forEach({ data in
//                var formatter = DateFormatter()
//                formatter.dateFormat = "yyyy/MM/dd"
//
//
//                let date =  formatter.string(from: data.dateComponents(for: Calendar.current).date!)
//
//                let count = data.appleStandHours.doubleValue(for: standUnit)
//                print(date, count)
//            })
//        }
//        healthStore.execute(query)
    }
}
