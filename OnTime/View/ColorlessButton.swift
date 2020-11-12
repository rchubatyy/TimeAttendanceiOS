//
//  ColorlessButton.swift
//  OnTime
//
//  Created by Roman Chubatyy on 08.11.2020.
//

import UIKit

class ColorlessButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
            super.awakeFromNib()
            backgroundColor = #colorLiteral(red: 0.2760762572, green: 0.3335207105, blue: 0.4444260597, alpha: 1)
            clipsToBounds = true
            layer.cornerRadius = 8
            layer.borderWidth = 1
            layer.borderColor = BUTTON_COLOR.cgColor
        }

}
