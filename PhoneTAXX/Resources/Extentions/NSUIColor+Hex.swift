//
//  NSUIColor+Hex.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 13/04/21.
//

import Foundation
import Charts

extension NSUIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component ")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 2.0)
    }
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 12) & 0xFF,
            green: (hex >> 10) & 0xFF,
            blue: hex & 0xFF
        )
    }
}
