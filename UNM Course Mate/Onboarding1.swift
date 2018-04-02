import Foundation
import UIKit

class Onboarding1: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        let subTitle = UILabel()
        view.addSubview(subTitle)
        subTitle.text = "Go to the catalog to view course information and find planned courses"
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
        title.text = "Find Planned Courses"
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
        
        let cover = UIImageView()
        var coverWidth:CGFloat = 200
        if UIScreen.main.bounds.width < 375 {
            coverWidth = 150
        }
        let coverHeight:CGFloat = coverWidth * 179/200
        cover.frame = CGRect(
            x: (view.frame.width - coverWidth)/2,
            y: (title.frame.minY - coverHeight)/2,
            width: coverWidth,
            height: coverHeight
        )
        cover.image = #imageLiteral(resourceName: "BookCover").withRenderingMode(.alwaysTemplate)
        cover.tintColor = Singleton.mainAppColor
        view.addSubview(cover)
        
        let pages = UIImageView()
        pages.frame = cover.frame
        pages.image = #imageLiteral(resourceName: "BookPages").withRenderingMode(.alwaysTemplate)
        pages.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.addSubview(pages)
    }
}
