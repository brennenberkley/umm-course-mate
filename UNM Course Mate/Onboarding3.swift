import Foundation
import UIKit

class Onboarding3: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        let subTitle = UILabel()
        view.addSubview(subTitle)
        subTitle.text = "Go to my.unm.edu to register for your classes"
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
        title.text = "Register"
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
        
        let iconDots = UIImageView()
        
        var iconWidth:CGFloat = 200
        if UIScreen.main.bounds.width < 375 {
            iconWidth = 150
        }
        let iconHeight:CGFloat = iconWidth * 180/200
        
        iconDots.frame = CGRect(
            x: (view.frame.width - iconWidth)/2,
            y: (title.frame.minY - iconHeight)/2,
            width: iconWidth,
            height: iconHeight
        )
        iconDots.image = #imageLiteral(resourceName: "registerDots").withRenderingMode(.alwaysTemplate)
        iconDots.tintColor = Singleton.mainAppColor
        view.addSubview(iconDots)
        
        let iconText = UIImageView()
        iconText.frame = iconDots.frame
        iconText.image = #imageLiteral(resourceName: "registerText").withRenderingMode(.alwaysTemplate)
        iconText.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.addSubview(iconText)
        
        let button = UIButton()
        view.addSubview(button)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel!.font = .preferredFont(forTextStyle: .title2)
        button.backgroundColor = Singleton.mainAppColor
        button.layer.cornerRadius = 5
        button.frame = CGRect(
            x: 40,
            y: view.frame.height - 125,
            width: view.frame.width - 80,
            height: 50
        )
    }
    
    func close() {
        UIApplication.shared.isStatusBarHidden = false
        Singleton.onboardingDone = true
        UserDefaults.standard.set(Singleton.onboardingDone, forKey: "onboardingDone")
        dismiss(animated: true, completion: nil)
    }
}
