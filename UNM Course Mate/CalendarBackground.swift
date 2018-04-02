import Foundation
import UIKit

class CalendarBackground: UIView {
    
    var dayWidth: CGFloat!
    var hourHeight: CGFloat!
    var labelWidth: CGFloat!
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(1/UIScreen.main.scale)
        let gray: [CGFloat] = [0.8, 0.8, 0.8, 1]
        context.setStrokeColor(CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: gray)!)
        
        // horizontal
        var hourPosition:CGFloat = 0
        while hourPosition < bounds.height {
            context.move(to: CGPoint(x: labelWidth.roundedForPixels(), y: hourPosition.roundedForPixels()))
            context.addLine(to: CGPoint(x: bounds.width.roundedForPixels(), y: hourPosition.roundedForPixels()))
            context.strokePath()
            hourPosition = hourPosition + hourHeight
        }
        
        // vertical
        var dayPosition = (dayWidth + labelWidth)
        while dayPosition < bounds.width {
            context.move(to: CGPoint(x: dayPosition.roundedForPixels(), y: CGFloat(0).roundedForPixels()))
            context.addLine(to: CGPoint(x: dayPosition.roundedForPixels(), y: bounds.height.roundedForPixels()))
            context.strokePath()
            dayPosition = dayPosition + dayWidth
        }
        
        // horizontal dashed
        context.setLineDash(phase: 0, lengths: [3,3])
        let lightGray: [CGFloat] = [0.85, 0.85, 0.85, 1]
        context.setStrokeColor(CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: lightGray)!)
        
        var halfHourPsition = hourHeight/2
        while halfHourPsition < bounds.height {
            context.move(to: CGPoint(x: labelWidth.roundedForPixels(), y: halfHourPsition.roundedForPixels()))
            context.addLine(to: CGPoint(x: bounds.width.roundedForPixels(), y: halfHourPsition.roundedForPixels()))
            context.strokePath()
            halfHourPsition = halfHourPsition + hourHeight
        }
    }
}
