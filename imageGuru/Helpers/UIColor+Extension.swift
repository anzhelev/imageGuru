//
//  UIColor+Extensions.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 05.02.2024.
//
import UIKit

extension UIColor {
    static var igRed: UIColor {UIColor(named: "YP Red") ?? UIColor.red}
    static var igBlue: UIColor {UIColor(named: "YP Blue") ?? UIColor.blue}
    static var igBlack: UIColor {UIColor(named: "YP Black") ?? UIColor.black}
    static var igBackground: UIColor {UIColor(named: "YP Background") ?? UIColor.darkGray}
    static var igGray: UIColor {UIColor(named: "YP Gray") ?? UIColor.gray}
    static var igWhite: UIColor {UIColor(named: "YP White") ?? UIColor.white}
    static var igWhiteAlpha50: UIColor {UIColor(named: "YP White (Alpha 50)") ?? UIColor.white}
    static var igGradientAlpha0: UIColor {UIColor(named: "YP Gradient (Alpha 0)") ?? UIColor.lightGray}
    static var igGradientAlpha20: UIColor {UIColor(named: "YP Gradient (Alpha 20)") ?? UIColor.gray}
}
