//
//  StandDataTableViewCell.swift
//  Stand
//
//  Created by HikikomoriMaster on 2018/11/17.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class StandDataTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    let viewColor = BlueColor.getColor(tone: .vp)
 
    func setData(date: String, standData: [StandData]) {
        dateLabel.text = date
        
        for i in 8...17 {
            let view = self.viewWithTag(i)
            view!.backgroundColor = UIColor.white
            view!.layer.borderColor = viewColor.cgColor
        }
        
        standData.forEach({ data in
            if data.start > 0 {
                if data.stood == HKCategoryValueAppleStandHour.stood.rawValue {
                    let view = self.viewWithTag(data.start)
                    view?.backgroundColor = viewColor
                }
            }
        })
    }

}
