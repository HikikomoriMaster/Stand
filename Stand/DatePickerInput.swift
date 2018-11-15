//
//  DatePickerInput.swift
//  Stand
//
//  Created by 深石祐太朗 on 2018/11/15.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import Foundation
import UIKit

// https://qiita.com/Simmon/items/5f8aae6b23e3c82cb735
extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

// https://qiita.com/wai21/items/c25740cbf1ce0c031eff
class DatePickerInput: UITextField {
    private var datePicker: UIDatePicker!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commoninit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commoninit()
    }
    
    private func commoninit() {
        // datePickerの設定
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(setText), for: .valueChanged)
        
        // textFieldのtextに日付を表示する
        setText()
        
        inputView = datePicker
        inputAccessoryView = createToolbar()
        
        // 枠無しのUITextFieldに下線をつける
        let borderColor: UIColor = BlueColor.getColor(palette: .g)
        addBorderBottom(height: 3.0, color: borderColor)
        addBorderBottom(height: 3.0, color: borderColor)
    }
    
    // キーボードのアクセサリービューを作成する
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let todayButtonItem = UIBarButtonItem(title: "Today", style: .done, target: self, action: #selector(todayPicker))
        let doneButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        let toolbarItems = [flexSpaceItem, todayButtonItem, doneButtonItem, space]
        
        toolbar.setItems(toolbarItems, animated: true)
        
        return toolbar
    }
    
    // キーボードの完了ボタンタップ時に呼ばれる
    @objc private func donePicker() {
        resignFirstResponder()
    }
    // キーボードの今日ボタンタップ時に呼ばれる
    @objc private func todayPicker() {
        datePicker.date = Date()
        setText()
    }
    
    // datePickerの日付けをtextFieldのtextに反映させる
    @objc private func setText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        text = formatter.string(from: datePicker.date)
    }
    
    // クラス外から日付を取り出すためのメソッド
    func getDate() -> Date {
        return datePicker.date
    }
    
    // コピペ等禁止
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    // カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}
