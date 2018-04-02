import Foundation
import UIKit

class Onboarding2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        let subTitle = UILabel()
        view.addSubview(subTitle)
        subTitle.text = "Use filters to find the perfect schedule for you"
        subTitle.font = .preferredFont(forTextStyle: .title3)
        subTitle.textColor = .white
        subTitle.textAlignment = .center
        subTitle.numberOfLines = 0
        subTitle.frame = CGRect(
            x: 15,
            y: 0,
            width: view.frame.width - 30,
            height: 200
        )
        subTitle.sizeToFit()
        subTitle.frame = CGRect(
            x: 15,
            y: view.frame.height - 170 - subTitle.frame.height,
            width: view.frame.width - 30,
            height: subTitle.frame.height
        )
        
        let title = UILabel()
        view.addSubview(title)
        title.text = "Create a Schedule"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textColor = .white
        title.textAlignment = .center
        title.numberOfLines = 0
        title.frame = CGRect(
            x: 15,
            y: 0,
            width: view.frame.width - 30,
            height: 200
        )
        title.sizeToFit()
        title.frame = CGRect(
            x: 15,
            y: subTitle.frame.minY - 10 - title.frame.height,
            width: view.frame.width - 30,
            height: title.frame.height
        )
        
        let filter = UIImageView()
        var filterWidth:CGFloat = 200
        if UIScreen.main.bounds.width < 375 {
            filterWidth = 150
        }
        let filterHeight:CGFloat = filterWidth
        filter.frame = CGRect(
            x: (view.frame.width - filterWidth)/2,
            y: (title.frame.minY - filterHeight)/2,
            width: filterWidth,
            height: filterHeight
        )
        filter.image = #imageLiteral(resourceName: "filter").withRenderingMode(.alwaysTemplate)
        filter.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.addSubview(filter)
        
        let filterCircles = UIImageView()
        filterCircles.frame = filter.frame
        filterCircles.image = #imageLiteral(resourceName: "filterCircles").withRenderingMode(.alwaysTemplate)
        filterCircles.tintColor = Singleton.mainAppColor
        view.addSubview(filterCircles)
    }
}
