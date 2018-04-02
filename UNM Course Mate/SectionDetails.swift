import Foundation
import UIKit

class SectionDetails: UIViewController {
    
    var delegate: AppDelegateProtocol!
    var section: Section!
    let container = UIScrollView()
    let courseTitle = UILabel()
    let titleDivider = UIView()
    var showSearch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Section \(section.sectionID)"
        if showSearch {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(
                barButtonSystemItem: .search,
                target: self,
                action: #selector(search)
            )
        }
        
        container.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        view.addSubview(container)
        
        container.addSubview(courseTitle)
        courseTitle.font = .preferredFont(forTextStyle: .title1)
        courseTitle.text = section.courseTitle
        courseTitle.textAlignment = .center
        courseTitle.frame = CGRect(
            x: 30,
            y: 10,
            width: container.frame.width - 60,
            height: container.frame.height
        )
        courseTitle.numberOfLines = 2
        courseTitle.sizeToFit()
        courseTitle.frame = CGRect(
            x: 30,
            y: 10,
            width: container.frame.width - 60,
            height: courseTitle.frame.height
        )
        
        container.addSubview(titleDivider)
        titleDivider.backgroundColor = Singleton.grayDividerColor
        titleDivider.frame = CGRect(
            x: 10,
            y: courseTitle.frame.maxY + 10,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        if section.status == "A" {
            layoutContent()
        } else {
            let message = UILabel()
            container.addSubview(message)
            message.font = .preferredFont(forTextStyle: .title3)
            message.text = "This section has been cancelled"
            message.frame = CGRect(
                x: 10,
                y: titleDivider.frame.maxY + 15,
                width: container.frame.width - 20,
                height: 100
            )
            message.sizeToFit()
            message.frame = CGRect(
                x: 10,
                y: titleDivider.frame.maxY + 15,
                width: container.frame.width - 20,
                height: message.frame.height
            )
        }
    }
    
    func layoutContent() {
        
        let creditsLabel = UILabel()
        container.addSubview(creditsLabel)
        creditsLabel.text = "credits"
        creditsLabel.textColor = Singleton.mainAppColor
        creditsLabel.font = .preferredFont(forTextStyle: .callout)
        creditsLabel.sizeToFit()
        creditsLabel.frame = CGRect(
            x: 10,
            y: courseTitle.frame.maxY + 15,
            width: container.frame.width - 20,
            height: creditsLabel.frame.height
        )
        
        let credits = UILabel()
        container.addSubview(credits)
        credits.text = "\(section.credits)"
        credits.font = .preferredFont(forTextStyle: .title3)
        credits.sizeToFit()
        credits.frame = CGRect(
            x: 10,
            y: creditsLabel.frame.maxY + 2,
            width: container.frame.width - 20,
            height: credits.frame.height
        )
        
        let divider0 = UIView()
        container.addSubview(divider0)
        divider0.backgroundColor = Singleton.grayDividerColor
        divider0.frame = CGRect(
            x: 10,
            y: credits.frame.maxY + 5,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        let instructorLabel = UILabel()
        container.addSubview(instructorLabel)
        if section.instructors.count > 1 {
            instructorLabel.text = "instructors"
        } else {
            instructorLabel.text = "instructor"
        }
        instructorLabel.textColor = Singleton.mainAppColor
        instructorLabel.font = .preferredFont(forTextStyle: .callout)
        instructorLabel.sizeToFit()
        instructorLabel.frame = CGRect(
            x: 10,
            y: credits.frame.maxY + 10,
            width: container.frame.width - 20,
            height: instructorLabel.frame.height
        )
        
        let instructor = UILabel()
        container.addSubview(instructor)
        if section.instructors.count == 1 {
            instructor.text = "\(section.instructors.first!.first) \(section.instructors.first!.last)"
        } else if section.instructors.count == 0 {
            instructor.text = "TBA"
        } else {
            instructor.text = ""
            for i in 0...(section.instructors.count - 1) {
                let teacher = section.instructors[i]
                instructor.text?.append("\(teacher.first) \(teacher.last)")
                if i != section.instructors.count - 1 {
                    instructor.text?.append("\n")
                }
            }
        }
        instructor.numberOfLines = 0
        instructor.font = .preferredFont(forTextStyle: .title3)
        instructor.adjustsFontSizeToFitWidth = true
        instructor.minimumScaleFactor = 0.7
        instructor.sizeToFit()
        instructor.frame = CGRect(
            x: 10,
            y: instructorLabel.frame.maxY + 2,
            width: container.frame.width - 20,
            height: instructor.frame.height
        )
        
        let divider1 = UIView()
        container.addSubview(divider1)
        divider1.backgroundColor = Singleton.grayDividerColor
        divider1.frame = CGRect(
            x: 10,
            y: instructor.frame.maxY + 5,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        let courseNumberLabel = UILabel()
        container.addSubview(courseNumberLabel)
        courseNumberLabel.text = "course number"
        courseNumberLabel.textColor = Singleton.mainAppColor
        courseNumberLabel.font = .preferredFont(forTextStyle: .callout)
        courseNumberLabel.sizeToFit()
        courseNumberLabel.frame = CGRect(
            x: 10,
            y: instructor.frame.maxY + 10,
            width: container.frame.width - 20,
            height: courseNumberLabel.frame.height
        )
        
        let courseNumber = UILabel()
        container.addSubview(courseNumber)
        courseNumber.text = "\(section.subjectID) \(section.courseID)-\(section.sectionID)"
        courseNumber.numberOfLines = 0
        courseNumber.font = .preferredFont(forTextStyle: .title3)
        courseNumber.sizeToFit()
        courseNumber.frame = CGRect(
            x: 10,
            y: courseNumberLabel.frame.maxY + 2,
            width: container.frame.width - 20,
            height: courseNumber.frame.height
        )
        
        let divider2 = UIView()
        container.addSubview(divider2)
        divider2.backgroundColor = Singleton.grayDividerColor
        divider2.frame = CGRect(
            x: 10,
            y: courseNumber.frame.maxY + 5,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        let crnLabel = UILabel()
        container.addSubview(crnLabel)
        crnLabel.text = "crn"
        crnLabel.textColor = Singleton.mainAppColor
        crnLabel.font = .preferredFont(forTextStyle: .callout)
        crnLabel.sizeToFit()
        crnLabel.frame = CGRect(
            x: 10,
            y: courseNumber.frame.maxY + 10,
            width: container.frame.width - 20,
            height: crnLabel.frame.height
        )
        
        let crn = UILabel()
        container.addSubview(crn)
        crn.text = section.crn
        crn.numberOfLines = 0
        crn.font = .preferredFont(forTextStyle: .title3)
        crn.sizeToFit()
        crn.frame = CGRect(
            x: 10,
            y: crnLabel.frame.maxY + 2,
            width: container.frame.width - 20,
            height: crn.frame.height
        )
        
        let divider3 = UIView()
        container.addSubview(divider3)
        divider3.backgroundColor = Singleton.grayDividerColor
        divider3.frame = CGRect(
            x: 10,
            y: crn.frame.maxY + 5,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        let enrollmentLabel = UILabel()
        container.addSubview(enrollmentLabel)
        enrollmentLabel.text = "enrollment"
        enrollmentLabel.textColor = Singleton.mainAppColor
        enrollmentLabel.font = .preferredFont(forTextStyle: .callout)
        enrollmentLabel.sizeToFit()
        enrollmentLabel.frame = CGRect(
            x: 10,
            y: crn.frame.maxY + 10,
            width: enrollmentLabel.frame.width,
            height: enrollmentLabel.frame.height
        )
        
        let enrollment = UILabel()
        container.addSubview(enrollment)
        
        enrollment.text = "\(section.enrollment)/\(section.enrollmentMax)"
        enrollment.numberOfLines = 0
        enrollment.font = .preferredFont(forTextStyle: .title3)
        enrollment.sizeToFit()
        enrollment.frame = CGRect(
            x: 10,
            y: enrollmentLabel.frame.maxY + 2,
            width: enrollment.frame.width,
            height: enrollment.frame.height
        )
        if section.enrollmentMax != 0 {
            if section.enrollment >= section.enrollmentMax {
                var xPosition:CGFloat = 0
                if enrollmentLabel.frame.maxX > xPosition { xPosition = enrollmentLabel.frame.maxX }
                if enrollment.frame.maxX > xPosition { xPosition = enrollment.frame.maxX }
                let waitlistLabel = UILabel()
                container.addSubview(waitlistLabel)
                waitlistLabel.text = "waitlist"
                waitlistLabel.textColor = Singleton.mainAppColor
                waitlistLabel.font = .preferredFont(forTextStyle: .callout)
                waitlistLabel.frame = CGRect(
                    x: xPosition + 30,
                    y: crn.frame.maxY + 10,
                    width: container.frame.width - (xPosition + 30) - 10,
                    height: enrollmentLabel.frame.height
                )
                
                let waitlist = UILabel()
                container.addSubview(waitlist)
                waitlist.text = "\(section.waitlist)/\(section.waitlistMax)"
                waitlist.numberOfLines = 0
                waitlist.font = .preferredFont(forTextStyle: .title3)
                waitlist.sizeToFit()
                waitlist.frame = CGRect(
                    x: xPosition + 30,
                    y: waitlistLabel.frame.maxY + 2,
                    width: container.frame.width - (xPosition + 30) - 10,
                    height: waitlist.frame.height
                )
            }
        }
        
        let divider4 = UIView()
        container.addSubview(divider4)
        divider4.backgroundColor = Singleton.grayDividerColor
        divider4.frame = CGRect(
            x: 10,
            y: enrollment.frame.maxY + 5,
            width: container.frame.width - 10,
            height: 1/UIScreen.main.scale
        )
        
        let timesLabel = UILabel()
        container.addSubview(timesLabel)
        timesLabel.text = "meeting times"
        timesLabel.textColor = Singleton.mainAppColor
        timesLabel.font = .preferredFont(forTextStyle: .callout)
        timesLabel.sizeToFit()
        timesLabel.frame = CGRect(
            x: 10,
            y: enrollment.frame.maxY + 10,
            width: container.frame.width - 20,
            height: timesLabel.frame.height
        )
        
        //MARK: Meeting Times
        let timesContainer = UIView()
        container.addSubview(timesContainer)
        timesContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: container.frame.width,
            height: container.frame.height
        )
        
        var timeViews = [UIView]()
        
        var timesDividerWidth:CGFloat = 0
        
        if section.isOnline {
            let timeView = UIView()
            timeViews.append(timeView)
            timesContainer.addSubview(timeView)
            let online = UILabel()
            online.font = .preferredFont(forTextStyle: .title3)
            online.text = "Online"
            online.sizeToFit()
            online.frame = CGRect(
                x: 10,
                y: 0,
                width: online.frame.width,
                height: online.frame.height
            )
            timeView.addSubview(online)
            timeView.frame = CGRect(
                x: 0,
                y: 0,
                width: container.frame.width,
                height: online.frame.maxY
            )
        } else {
            for meetingTime in section.meetingTimes {
                let timeView = UIView()
                timeViews.append(timeView)
                
                timesContainer.addSubview(timeView)
                
                // Format the time label
                let startRemainder = meetingTime.startTime%100
                let startTimeHour:CGFloat = CGFloat(meetingTime.startTime - startRemainder)/100
                let endRemainder = meetingTime.endTime%100
                let endTimeHour:CGFloat = CGFloat(meetingTime.endTime - endRemainder)/100
                var startLabel = ""
                var endLabel = ""
                if startRemainder == 0 {
                    if startTimeHour <= 12 {
                        startLabel = "\(Int(startTimeHour)):00"
                    } else {
                        startLabel = "\(Int(startTimeHour) - 12):00"
                    }
                } else {
                    if startTimeHour <= 12 {
                        startLabel = "\(Int(startTimeHour)):\(startRemainder)"
                    } else {
                        startLabel = "\(Int(startTimeHour) - 12):\(startRemainder)"
                    }
                }
                
                if endRemainder == 0 {
                    if endTimeHour <= 12 {
                        endLabel = "\(Int(endTimeHour)):00"
                    } else {
                        endLabel = "\(Int(endTimeHour) - 12):00"
                    }
                } else {
                    if endTimeHour <= 12 {
                        endLabel = "\(Int(endTimeHour)):\(endRemainder)"
                    } else {
                        endLabel = "\(Int(endTimeHour) - 12):\(endRemainder)"
                    }
                }
                
                let time = UILabel()
                timeView.addSubview(time)
                time.text = "\(startLabel) - \(endLabel)"
                time.font = .preferredFont(forTextStyle: .title3)
                time.adjustsFontSizeToFitWidth = true
                time.minimumScaleFactor = 0.7
                time.sizeToFit()
                time.frame = CGRect(
                    x: 10,
                    y: 0,
                    width: time.frame.width,
                    height: time.frame.height
                )
                
                let days = UILabel()
                timeView.addSubview(days)
                days.text = ""
                for day in meetingTime.days {
                    if day == "M" {
                        days.text!.append("Mon")
                    } else if day == "T" {
                        days.text!.append("Tues")
                    } else if day == "W" {
                        days.text!.append("Wed")
                    } else if day == "R" {
                        days.text!.append("Thurs")
                    } else if day == "F" {
                        days.text!.append("Fri")
                    } else if day == "S" {
                        days.text!.append("Sat")
                    } else if day == "U" {
                        days.text!.append("Sun")
                    }
                    if day != meetingTime.days.last {
                        days.text!.append(", ")
                    }
                }
                days.font = .preferredFont(forTextStyle: .title3)
                days.adjustsFontSizeToFitWidth = true
                days.minimumScaleFactor = 0.7
                days.sizeToFit()
                days.frame = CGRect(
                    x: time.frame.maxX + 30,
                    y: 0,
                    width: days.frame.width,
                    height: days.frame.height
                )
                
                if days.frame.maxX > (container.frame.width - 10) {
                    days.frame = CGRect(
                        x: time.frame.maxX + 30,
                        y: 0,
                        width: container.frame.width - (time.frame.maxX + 30) - 10,
                        height: days.frame.height
                    )
                }
                
                if days.frame.maxX > timesDividerWidth { timesDividerWidth = days.frame.maxX }
                
                let location = UILabel()
                timeView.addSubview(location)
                location.text = "\(meetingTime.building) \(meetingTime.room)"
                location.font = .preferredFont(forTextStyle: .body)
                location.adjustsFontSizeToFitWidth = true
                location.minimumScaleFactor = 0.7
                location.sizeToFit()
                location.frame = CGRect(
                    x: 10,
                    y: time.frame.maxY,
                    width: location.frame.width,
                    height: location.frame.height
                )
                if timeViews.count == 1 {
                    timeView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: container.frame.width,
                        height: location.frame.maxY
                    )
                } else {
                    timeView.frame = CGRect(
                        x: 0,
                        y: timeViews[timeViews.count - 2].frame.maxY + 15,
                        width: container.frame.width,
                        height: location.frame.maxY
                    )
                }
                if location.frame.maxX > timesDividerWidth { timesDividerWidth = location.frame.maxX }
            }
        }
        
        if timeViews.count > 1 {
            for i in 0...timeViews.count - 2 {
                let divider = UIView()
                timesContainer.addSubview(divider)
                divider.backgroundColor = Singleton.grayDividerColor
                divider.frame = CGRect(
                    x: 10,
                    y: timeViews[i].frame.maxY + 7,
                    width: timesDividerWidth - 10,
                    height: 1/UIScreen.main.scale
                )
            }
        }
        
        if timeViews.count > 0 {
            timesContainer.frame = CGRect(
                x: 0,
                y: timesLabel.frame.maxY + 2,
                width: container.frame.width,
                height: timeViews.last!.frame.maxY
            )
        } else {
            timesContainer.frame = CGRect(
                x: 0,
                y: timesLabel.frame.maxY + 2,
                width: container.frame.width,
                height: 0
            )
        }
        
        //MARK: Button
        var tabBarHeight:CGFloat = 0
        if let tabs = tabBarController {
            tabBarHeight = tabs.tabBar.frame.height
        }
        
        if timesContainer.frame.maxY + 20 > view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + tabBarHeight) {
            container.contentSize = CGSize(width: container.frame.width, height: timesContainer.frame.maxY + 20)
        } else {
            container.contentSize = CGSize(
                width: container.frame.width,
                height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + tabBarHeight)
            )
        }
    }
    
    func search() {
        let searchView = Search()
        searchView.delegate = delegate
        searchView.modalPresentationStyle = .popover
        navigationController?.present(searchView, animated: false, completion: nil)
    }    
}
