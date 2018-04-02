import Foundation
import UIKit

extension CGFloat {
    func roundedForPixels() -> CGFloat {
        var rounded: CGFloat!
        var remainder = self - floor(self)
        let pixelWidth = 1/UIScreen.main.scale
        while remainder >= pixelWidth {
            remainder = remainder - pixelWidth
        }
        let distance = pixelWidth/2 - remainder
        rounded = self + distance
        return rounded
    }
}
