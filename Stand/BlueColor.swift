//
//  BlueColor.swift
//  Stand
//
//  Created by HikikomoriMaster on 2018/11/15.
//  Copyright © 2018 HikikomoriMaster. All rights reserved.
//

import Foundation
import UIKit

// https://qiita.com/Kyomesuke3/items/eae6216b13c651254f64
extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let hex_ = hex.replacingOccurrences(of: "#", with: "")
        let v = hex_.map { String($0) } + Array(repeating: "0", count: max(6 - hex_.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}

class BlueColor: UIColor {
    
    // https://www.color-hex.com/color-palette/1294
    enum Palette: String {
        case vd = "#011f4b"
        case vg = "#03396c"
        case g  = "#005b96"
        case pg = "#6497b1"
        case vp = "#b3cde0"
    }

    static func getColor(palette :Palette) -> UIColor {
        return UIColor(hex: palette.rawValue)
    }
}
