import Foundation
import UIKit
import EventKit

class NoSchedules: UIViewController {
    
    var delegate: CreateScheduleProtocol!
    let container = UIView()
    var label = UILabel()
    var subLabel = UILabel()
    var conflictingCourses: [ScheduleSection]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Create Schedule"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            title: "Next",
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.rightBarButtonItem!.isEnabled = false
        
        let backItem = UIBarButtonItem(title: "Filter", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        container.addSubview(label)
        label.text = "No schedules found"
        
        label.font = .systemFont(ofSize: 32, weight: UIFontWeightLight)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.frame = CGRect(
            x: 20,
            y: 40,
            width: container.frame.width - 40,
            height: 200
        )
        label.sizeToFit()
        label.frame = CGRect(
            x: 20,
            y: 40,
            width: container.frame.width - 40,
            height: label.frame.height
        )
        
        container.addSubview(subLabel)
        subLabel.textAlignment = .center
        subLabel.font = .preferredFont(forTextStyle: .title3)
        subLabel.numberOfLines = 0
        subLabel.frame = CGRect(
            x: 20,
            y: label.frame.maxY + 5,
            width: container.frame.width - 40,
            height: 200
        )
        subLabel.sizeToFit()
        subLabel.frame = CGRect(
            x: 20,
            y: label.frame.maxY + 5,
            width: container.frame.width - 40,
            height: subLabel.frame.height + 40
        )
        
        if !conflictingCourses.isEmpty {
            let conflict1Container = UIView()
            container.addSubview(conflict1Container)
            
            let conflict1Code = UILabel()
            conflict1Container.addSubview(conflict1Code)
            conflict1Code.text = "\(conflictingCourses[0].subjectID) \(conflictingCourses[0].courseID)"
            conflict1Code.font = .preferredFont(forTextStyle: .body)
            conflict1Code.adjustsFontSizeToFitWidth = true
            
            let conflict1 = UILabel()
            conflict1Container.addSubview(conflict1)
            conflict1.text = conflictingCourses[0].title
            conflict1.font = .preferredFont(forTextStyle: .body)
            conflict1.adjustsFontSizeToFitWidth = true
            
            let conflict2Container = UIView()
            container.addSubview(conflict2Container)
            
            let conflict2Code = UILabel()
            conflict2Container.addSubview(conflict2Code)
            conflict2Code.text = "\(conflictingCourses[1].subjectID) \(conflictingCourses[1].courseID)"
            conflict2Code.font = .preferredFont(forTextStyle: .body)
            conflict2Code.adjustsFontSizeToFitWidth = true
            
            let conflict2 = UILabel()
            conflict2Container.addSubview(conflict2)
            conflict2.text = conflictingCourses[1].title
            conflict2.font = .preferredFont(forTextStyle: .body)
            conflict2.adjustsFontSizeToFitWidth = true
            
            conflict1Code.frame = CGRect(
                x: 15,
                y: 0,
                width: 200,
                height: 44
            )
            conflict1Code.sizeToFit()
            conflict2Code.frame = CGRect(
                x: 15,
                y: 0,
                width: 200,
                height: 44
            )
            conflict2Code.sizeToFit()
            
            var codeWidth = conflict1Code.frame.width
            if conflict2Code.frame.width > codeWidth {
                codeWidth = conflict2Code.frame.width
            }
            
            conflict1Container.frame = CGRect(
                x: 0,
                y: subLabel.frame.maxY,
                width: container.frame.width,
                height: 44
            )
            conflict1Container.addBorder(color: .light, sides: [.bottom], inset: 15)
            conflict1Container.addBorder(color: .normal, sides: [.top])

            conflict1Code.frame = CGRect(
                x: 15,
                y: 0,
                width: codeWidth,
                height: 44
            )
            conflict1.frame = CGRect(
                x: conflict1Code.frame.maxX + 15,
                y: 0,
                width: container.frame.width - conflict1Code.frame.maxX - 30,
                height: 44
            )
            conflict2Container.frame = CGRect(
                x: 0,
                y: conflict1Container.frame.maxY,
                width: container.frame.width,
                height: 44
            )
            conflict2Container.addBorder(color: .normal, sides: [.bottom])

            conflict2Code.frame = CGRect(
                x: 15,
                y: 0,
                width: codeWidth,
                height: 44
            )
            conflict2.frame = CGRect(
                x: conflict2Code.frame.maxX + 15,
                y: 0,
                width: container.frame.width - conflict2Code.frame.maxX  - 30,
                height: 44
            )
        }
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
        delegate.closedModal(done: false)
    }
}
