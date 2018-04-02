import Foundation
import UIKit

extension UIView {
    func addBorder(color: BorderColor, sides: [BorderSide]) {
        var lineColor:CGColor!
        if color == .normal {
            lineColor = Singleton.grayDividerColor.cgColor
        } else if color == .light {
            lineColor = Singleton.lightGrayDividerColor.cgColor
        }
        for side in sides {
            let border = CALayer()
            border.backgroundColor = lineColor
            switch side {
            case BorderSide.top:
                border.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: self.frame.size.width,
                    height: 1/UIScreen.main.scale
                )
            case BorderSide.bottom:
                border.frame = CGRect(
                    x: 0,
                    y: self.frame.size.height - 1/UIScreen.main.scale,
                    width: self.frame.size.width,
                    height: 1/UIScreen.main.scale
                )
            case BorderSide.left:
                border.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: 1/UIScreen.main.scale,
                    height: self.frame.size.height
                )
            case BorderSide.right:
                border.frame = CGRect(
                    x: self.frame.size.width - 1/UIScreen.main.scale,
                    y: 0,
                    width: 1/UIScreen.main.scale,
                    height: self.frame.size.height
                )
            default: break
            }
            self.layer.addSublayer(border)
        }
    }
    
    func addBorder(color: BorderColor, sides: [BorderSide], inset: CGFloat) {
        var lineColor:CGColor!
        if color == .normal {
            lineColor = Singleton.grayDividerColor.cgColor
        } else if color == .light {
            lineColor = Singleton.lightGrayDividerColor.cgColor
        }
        for side in sides {
            let border = CALayer()
            border.backgroundColor = lineColor
            switch side {
            case BorderSide.top:
                border.frame = CGRect(
                    x: inset,
                    y: 0,
                    width: self.frame.size.width - inset,
                    height: 1/UIScreen.main.scale
                )
            case BorderSide.bottom:
                border.frame = CGRect(
                    x: inset,
                    y: self.frame.size.height - 1/UIScreen.main.scale,
                    width: self.frame.size.width - inset,
                    height: 1/UIScreen.main.scale
                )
            case BorderSide.left:
                border.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: 1/UIScreen.main.scale,
                    height: self.frame.size.height
                )
            case BorderSide.right:
                border.frame = CGRect(
                    x: self.frame.size.width - 1/UIScreen.main.scale,
                    y: 0,
                    width: 1/UIScreen.main.scale,
                    height: self.frame.size.height
                )
            default: break
            }
            self.layer.addSublayer(border)
        }
    }
}

struct BorderSide: OptionSet {
    let rawValue: Int
    static let top      = BorderSide(rawValue: 1 << 0)
    static let bottom   = BorderSide(rawValue: 1 << 1)
    static let left     = BorderSide(rawValue: 1 << 2)
    static let right    = BorderSide(rawValue: 1 << 3)
}

struct BorderColor: OptionSet {
    let rawValue: Int
    static let normal  = BorderColor(rawValue: 1 << 0)
    static let light   = BorderColor(rawValue: 1 << 1)
}
