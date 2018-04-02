import Foundation
import UIKit

class Calendar: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var delegate: CreateScheduleProtocol!
    var scrollView = UIScrollView()
    var events = [CalendarEvent]()
    var classesWithoutTimes = [ScheduleSection]()
    let background = CalendarBackground()
    var includeOnline: Bool!
    var includeFull: Bool!
    
    let container = UIView()

    var classSchedule: [ScheduleSection]!
    var color = 5 //cycles from 0 - 5 to select colors
    
    var classDays: [String]!
    var earliestTime: CGFloat!
    var latestTime: CGFloat!
    
    var table = UITableView()
    var codeWidth:CGFloat = 0
   
    var timeLabelWidth:CGFloat {
        let tempLabel = UILabel()
        tempLabel.text = "10 pm"
        tempLabel.font = .preferredFont(forTextStyle: .footnote)
        tempLabel.sizeToFit()
        return tempLabel.frame.width + 6
    }
    let labelHeight:CGFloat = 20
    let hourMargin:CGFloat = 6
    
    let noTimesHeader = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Create Schedule"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
        let backItem = UIBarButtonItem(title: "Calendar", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        
        container.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        for section in classSchedule {
            if section.meetingTimes.count == 0 {
                classesWithoutTimes.append(section)
            }
        }
        
        if classesWithoutTimes.count > 0 {
            for section in classesWithoutTimes {
                let tempLabel = UILabel()
                tempLabel.text = "\(section.subjectID)-\(section.courseID)"
                tempLabel.font = .preferredFont(forTextStyle: .body)
                tempLabel.sizeToFit()
                if tempLabel.frame.width > codeWidth {
                    codeWidth = tempLabel.frame.width
                }
            }
            container.addSubview(table)
            table.rowHeight = 44
            table.dataSource = self
            table.separatorInset.left = 15
            table.register(TableCell.self, forCellReuseIdentifier: "cell")
            table.isScrollEnabled = false
            table.frame = CGRect(
                x: 0,
                y: container.frame.height - (table.rowHeight * CGFloat(classesWithoutTimes.count + 1)),
                width: container.frame.height,
                height: table.rowHeight * CGFloat(classesWithoutTimes.count + 1)
            )
            
            container.addSubview(noTimesHeader)
            noTimesHeader.frame = CGRect(
                x: 0,
                y: table.frame.minY - 30,
                width: container.frame.width,
                height: 30
            )
            noTimesHeader.backgroundColor = Singleton.lightGrayBackgroundColor
            noTimesHeader.addBorder(color: .normal, sides: [.top, .bottom])
            let noTimesLabel = UILabel()
            noTimesLabel.text = "Classes with no meeting times"
            noTimesLabel.font = .preferredFont(forTextStyle: .body)
            noTimesLabel.textColor = Singleton.darkGrayTextColor
            noTimesHeader.addSubview(noTimesLabel)
            noTimesLabel.frame = CGRect(
                x: 15,
                y: 0,
                width: noTimesHeader.frame.width - 30,
                height: noTimesHeader.frame.height
            )
        }
        
        // Calculate calendar size based on classes
        var startDay = 0
        var endDay = 4
        
        if classDays.contains("M") {
            startDay = 0
        } else if classDays.contains("T") {
            startDay = 1
        } else if classDays.contains("W") {
            startDay = 2
        } else if classDays.contains("R") {
            startDay = 3
        } else if classDays.contains("F") {
            startDay = 4
        } else if classDays.contains("S") {
            startDay = 5
        } else if classDays.contains("U") {
            startDay = 6
        }
        
        if classDays.contains("U") {
            endDay = 6
        } else if classDays.contains("S") {
            endDay = 5
        } else if classDays.contains("F") {
            endDay = 4
        } else if classDays.contains("R") {
            endDay = 3
        } else if classDays.contains("W") {
            endDay = 2
        } else if classDays.contains("T") {
            endDay = 1
        } else if classDays.contains("M") {
            endDay = 0
        }
        
        let daysView = UIView()
        container.addSubview(daysView)
        container.addSubview(scrollView)
        
        daysView.frame = CGRect(
            x: 0,
            y: 0,
            width: container.frame.width,
            height: 25
        )
        daysView.backgroundColor = Singleton.lightGrayBackgroundColor
        daysView.addBorder(color: .normal, sides: [.bottom])
        scrollView.frame = CGRect(
            x: 0,
            y: daysView.frame.height,
            width: container.frame.width,
            height: container.frame.height - (daysView.frame.height + table.frame.height + noTimesHeader.frame.height)
        )
        
        let dayWidth:CGFloat = (container.frame.width - CGFloat(timeLabelWidth + hourMargin))/CGFloat(endDay - startDay + 1)
        let hourHeight:CGFloat = 80
        var startHour:CGFloat = 9
        if earliestTime - 0.5 < startHour {
            startHour = floor(earliestTime - 0.5)
        }
        var endHour:CGFloat = 17
        if latestTime + 0.5 > endHour {
            endHour = ceil(latestTime + 0.5)
        }
        var offsetHour:CGFloat = earliestTime - 0.5
        if (endHour - offsetHour)*hourHeight < scrollView.frame.height {
            offsetHour = endHour - scrollView.frame.height/hourHeight
        }
        let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayAbbreviations = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
        
        // layout calendar
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.contentSize.width = scrollView.bounds.width
        scrollView.contentSize.height = CGFloat(endHour - startHour) * hourHeight + 40
        scrollView.contentOffset = CGPoint(x: 0, y: (offsetHour - CGFloat(startHour))*hourHeight + 20)
        for i in startDay...endDay {
            let dayLabel = UILabel()
            if dayWidth < 75 {
                dayLabel.text = dayAbbreviations[i]
            } else {
                dayLabel.text = dayNames[i]
            }
            dayLabel.font = .preferredFont(forTextStyle: .footnote)
            dayLabel.textColor = Singleton.darkGrayTextColor
            dayLabel.textAlignment = .center
            let x = CGFloat(timeLabelWidth + hourMargin) + (dayWidth*CGFloat(i - startDay))
            dayLabel.frame = CGRect(
                x: x,
                y: 0,
                width: dayWidth,
                height: daysView.frame.height
            )
            daysView.addSubview(dayLabel)
        }
        
        background.backgroundColor = .white
        background.frame = CGRect(
            x: 0,
            y: 20,
            width: scrollView.bounds.width,
            height: hourHeight * CGFloat(endHour - startHour) + 1/UIScreen.main.scale
        )
        background.dayWidth = CGFloat(dayWidth)
        background.hourHeight = CGFloat(hourHeight)
        background.labelWidth = CGFloat(timeLabelWidth + hourMargin)
        scrollView.addSubview(background)
        for i in Int(startHour)...Int(endHour) {
            let label = UILabel()
            let y = (CGFloat(i) - startHour) * hourHeight - CGFloat(labelHeight/2)
            label.frame = CGRect(
                x: 0,
                y: y + 20,
                width: timeLabelWidth,
                height: labelHeight
            )
            label.font = .preferredFont(forTextStyle: .footnote)
            label.baselineAdjustment = .alignCenters
            label.textAlignment = .right
            label.textColor = Singleton.lightGrayTextColor
            if i < 12 {
                label.text = "\(i) am"
            } else if i == 12 {
                label.text = "\(i) pm"
            } else if i > 12 {
                label.text = "\(i-12) pm"
            }
            scrollView.addSubview(label)
        }
        for section in classSchedule {
            let activeColor = newColor()
            for time in section.meetingTimes {
                let startRemainder = time.startTime%100
                let startTimeHour:CGFloat = CGFloat(time.startTime - startRemainder)/100
                let start = startTimeHour + CGFloat(startRemainder)/60
                
                let endRemainder = time.endTime%100
                let endTimeHour:CGFloat = CGFloat(time.endTime - endRemainder)/100
                let end = endTimeHour + CGFloat(endRemainder)/60
                
                var days = [Int]()
                for day in time.days {
                    if day == "M" {
                        days.append(0)
                    } else if day == "T" {
                        days.append(1)
                    } else if day == "W" {
                        days.append(2)
                    } else if day == "R" {
                        days.append(3)
                    } else if day == "F" {
                        days.append(4)
                    } else if day == "S" {
                        days.append(5)
                    } else if day == "U" {
                        days.append(6)
                    }
                }
                
                for day in days {
                    let event = CalendarEvent()
                    events.append(event)
                    event.frame = CGRect(
                        x: CGFloat(timeLabelWidth + hourMargin) + CGFloat(day - startDay)*dayWidth,
                        y: (start - CGFloat(startHour)) * hourHeight + 20,
                        width: dayWidth,
                        height: hourHeight * (end - start)
                    )
                    event.backgroundColor = activeColor
                    event.layer.cornerRadius = 5
                    event.section = section
                    scrollView.addSubview(event)
                    
                    let code = UILabel()
                    code.text = "\(section.subjectID)-\(section.courseID)"
                    code.font = .preferredFont(forTextStyle: .body)
                    code.adjustsFontSizeToFitWidth = true
                    code.minimumScaleFactor = 0.8
                    code.sizeToFit()
                    code.frame = CGRect(
                        x: 4,
                        y: 4,
                        width: event.frame.width - 8,
                        height: code.frame.height
                    )
                    event.addSubview(code)
                    
                    let location = UILabel()
                    location.text = "\(time.buildingCode) \(time.room)"
                    location.font = .preferredFont(forTextStyle: .subheadline)
                    location.textColor = Singleton.darkGrayTextColor
                    location.adjustsFontSizeToFitWidth = true
                    location.minimumScaleFactor = 0.8
                    location.sizeToFit()
                    location.frame = CGRect(
                        x: 4,
                        y: code.frame.height + 4,
                        width: event.frame.width - 8,
                        height: location.frame.height
                    )
                    event.addSubview(location)
                    
                    let timeLabel = UILabel()
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
                    
                    timeLabel.text = "\(startLabel) - \(endLabel)"
                    timeLabel.font = .preferredFont(forTextStyle: .subheadline)
                    timeLabel.numberOfLines = 2
                    timeLabel.textColor = Singleton.darkGrayTextColor
                    timeLabel.frame = CGRect(
                        x: 4,
                        y: location.frame.maxY + 8,
                        width: dayWidth - 8,
                        height: 50
                    )
                    timeLabel.sizeToFit()
                    timeLabel.frame = CGRect(
                        x: 4,
                        y: location.frame.maxY + 8,
                        width: dayWidth - 8,
                        height: timeLabel.frame.height
                    )
                    if timeLabel.frame.maxY <= event.frame.height {
                        event.addSubview(timeLabel)
                    }
                }
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesWithoutTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        let section = classesWithoutTimes[indexPath.row]
        cell.codeWidth = codeWidth
        cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
        cell.code.text = "\(section.subjectID)-\(section.courseID)"
        cell.title.text = section.title
        cell.isUserInteractionEnabled = false
        cell.layout()
        return cell
    }
    
    func tap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended  else {
            return
        }
        let location = sender.location(in: scrollView)
        for event in events {
            guard location.x >= event.frame.minX && location.x <= event.frame.maxX else {
                continue
            }
            guard location.y >= event.frame.minY && location.y <= event.frame.maxY else {
                continue
            }
            // Get all sections that meet at a given time
            var possibleSections = findSections(input: event.section)
            if !includeFull {
                var filtered = [Section]()
                for section in possibleSections {
                    if section.enrollment < section.enrollmentMax {
                        filtered.append(section)
                    }
                }
                possibleSections = filtered
            }
            if !includeOnline {
                var filtered = [Section]()
                for section in possibleSections {
                    if !section.isOnline {
                        filtered.append(section)
                    }
                }
                possibleSections = filtered
            }
            
            if possibleSections.count == 1 {
                // Go directly to the section details page
                let destination = SectionDetails()
                destination.section = possibleSections.first!
                navigationController?.pushViewController(destination, animated: true)
            } else {
                // Display section selection page
                let destination = RegisterSections()
                destination.possibleSections = possibleSections
                navigationController?.pushViewController(destination, animated: true)
            }
        }
    }
    
    func nextPage() {
        var options = [[Section]]()
        // Go through each Schedule Section and find all actual sections that meet at that time.
        for time in classSchedule {
            var possibleSections = findSections(input: time)
            if !includeFull {
                var filtered = [Section]()
                for section in possibleSections {
                    if section.enrollment < section.enrollmentMax {
                        filtered.append(section)
                    }
                }
                possibleSections = filtered
            }
            if !includeOnline {
                var filtered = [Section]()
                for section in possibleSections {
                    if !section.isOnline {
                        filtered.append(section)
                    }
                }
                possibleSections = filtered
            }
            
            var activeSections = [Section]()
            for section in possibleSections {
                if section.status == "A" {
                    activeSections.append(section)
                }
            }
            possibleSections = activeSections

            options.append(possibleSections)
        }
        
        // If there is more than one section of a given class at the same time, have the user pick one
        var selectSections = false
        for i in options {
            if i.count > 1 {
                selectSections = true
            }
        }
        
        if selectSections {
            let destination = RegisterSections()
            destination.delegate = delegate
            destination.registering = true
            destination.options = options
            navigationController?.pushViewController(destination, animated: true)
        } else {
            // If no times have more than one section:
            let destination = Register()
            destination.delegate = delegate
            for i in options {
                destination.selectedSections.append(i.first!)
            }
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    func findSections(input: ScheduleSection) -> [Section] {
        var possibleSections = [Section]()
        let subjectIndex = Singleton.schedule[Singleton.semesterIndex].subjects.index(where: {$0.subjectID == input.subjectID})
        let courses = Singleton.schedule[Singleton.semesterIndex].subjects[subjectIndex!].courses
        let courseIndex = courses.index(where: {$0.courseID == input.courseID})
        let sections = courses[courseIndex!].sections
        for section in sections {
            if section.isSameTimeAs(comparison: input.meetingTimes) {
                possibleSections.append(section)
            }
        }
        return possibleSections
    }
    
    func newColor() -> UIColor {
        var colors = [UIColor]()
        //blue
        colors.append(UIColor(red: 0.5, green: 0.8, blue: 1, alpha: 0.7))
        //red
        colors.append(UIColor(red: 1, green: 0.4, blue: 0.4, alpha: 0.7))
        //green
        colors.append(UIColor(red: 0.3, green: 1, blue: 0.4, alpha: 0.7))
        //yellow
        colors.append(UIColor(red: 1, green: 1, blue: 0.2, alpha: 0.7))
        //purple
        colors.append(UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 0.7))
        //orange
        colors.append(UIColor(red: 1, green: 0.6, blue: 0.3, alpha: 0.7))
        if color < 5 {
            color = color + 1
        } else {
            color = 0
        }
        return colors[color]
    }
    
    class CalendarEvent: UIView {
        var section:ScheduleSection!
    }
    
    class TableCell: UITableViewCell {
        
        var code = UILabel()
        var title = UILabel()
        
        var cellSize: CGSize!
        var codeWidth: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            code.font = .preferredFont(forTextStyle: .body)
            contentView.addSubview(code)
            
            title.font = .preferredFont(forTextStyle: .body)
            title.adjustsFontSizeToFitWidth = true
            title.minimumScaleFactor = 0.8
            contentView.addSubview(title)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            code.frame = CGRect(
                x: 15,
                y: 0,
                width: codeWidth,
                height: cellSize.height
            )
            
            title.frame = CGRect(
                x: code.frame.maxX + 15,
                y: 0,
                width: cellSize.width - code.frame.maxX - 30,
                height: cellSize.height
            )
        }
    }
}
