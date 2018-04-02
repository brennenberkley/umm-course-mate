import Foundation
import UIKit

class SelectSchedule: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: CreateScheduleProtocol!
    var label = UILabel()
    var subLabel = UILabel()
    var table = UITableView()
    var earliestTime: Date?
    var latestTime: Date?
    var availableDays: [Bool]! // S, M, T, W, T, F, S
    var days = [String]()
    var includeOnline: Bool!
    var includeFull: Bool!
    var timeWidth: CGFloat!
    var useFilter = true
    
    var possibleSchedules = [[ScheduleSection]]()
    var filteredSchedules = [[ScheduleSection]]()
    var classDays = [[String]]()
    var earliestTimes = [CGFloat]()
    var latestTimes = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Create Schedule"
        let backItem = UIBarButtonItem(title: "Schedules", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        // Filter schedules
        if availableDays[0] { days.append("U") }
        if availableDays[1] { days.append("M") }
        if availableDays[2] { days.append("T") }
        if availableDays[3] { days.append("W") }
        if availableDays[4] { days.append("R") }
        if availableDays[5] { days.append("F") }
        if availableDays[6] { days.append("S") }
        
        var earliest: Int!
        if let date = earliestTime {
            let hour = NSCalendar.current.component(.hour, from: date)
            let minutes = NSCalendar.current.component(.minute, from: date)
            earliest = hour*100 + minutes
        } else {
            earliest = 0
        }
        var latest: Int!
        if let date = latestTime {
            let hour = NSCalendar.current.component(.hour, from: date)
            let minutes = NSCalendar.current.component(.minute, from: date)
            latest = hour*100 + minutes
        } else {
            latest = 2400
        }
        
        for schedule in possibleSchedules {
            var valid = true
            for section in schedule {
                for time in section.meetingTimes {
                    if time.startTime < earliest {
                        valid = false
                        break
                    } else if time.endTime > latest {
                        valid = false
                        break
                    } else {
                        for day in time.days {
                            if !days.contains(day) {
                                valid = false
                                break
                            }
                        }
                    }
                }
            }
            if valid {
                filteredSchedules.append(schedule)
            }
        }
        
        // filter out full sections
        if !includeFull {
            var notFull = [[ScheduleSection]]()
            for schedule in filteredSchedules {
                var full = false
                for scheduleSection in schedule {
                    var allSectionsFull = true
                    let possibleSections = findSections(input: scheduleSection)
                    for section in possibleSections {
                        if section.status == "A" && section.enrollment < section.enrollmentMax {
                            allSectionsFull = false
                            break
                        }
                    }
                    if allSectionsFull {
                        full = true
                        break
                    }
                }
                if !full {
                    notFull.append(schedule)
                }
            }
            filteredSchedules = notFull
        }
        
        // filter out online sections
        if !includeOnline {
            var notOnline = [[ScheduleSection]]()
            for schedule in filteredSchedules {
                var online = false
                for scheduleSection in schedule {
                    var allSectionsOnline = true
                    let possibleSections = findSections(input: scheduleSection)
                    for section in possibleSections {
                        if section.status == "A" && !section.isOnline {
                            allSectionsOnline = false
                            break
                        }
                    }
                    if allSectionsOnline {
                        online = true
                        break
                    }
                }
                if !online {
                    notOnline.append(schedule)
                }
            }
            filteredSchedules = notOnline
        }
        
        if filteredSchedules.isEmpty {
            useFilter = false
            includeOnline = true
            includeFull = true
        }
        
        //Page Layout
        self.edgesForExtendedLayout = []
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height - (navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)
        )
        view.addSubview(container)
        
        container.addSubview(label)
        container.addSubview(table)
        
        if useFilter {
            label.text = "Select a schedule"
            label.font = .preferredFont(forTextStyle: .title1)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.frame = CGRect(
                x: 20,
                y: 0,
                width: container.frame.width - 40,
                height: 120
            )
        } else { // no schedules found
            container.addSubview(label)
            container.addSubview(subLabel)
            label.text = "No Schedules found"
            subLabel.text = "Here are the results without the filter"
            
            label.font = .preferredFont(forTextStyle: .title1)
            label.textAlignment = .center
            label.numberOfLines = 0
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
                height: subLabel.frame.height
            )
        }
        
        let header = UIView()
        container.addSubview(header)
        if useFilter {
            header.frame = CGRect(
                x: 0,
                y: label.frame.maxY,
                width: container.frame.width,
                height: 30
            )
        } else {
            header.frame = CGRect(
                x: 0,
                y: subLabel.frame.maxY + 40,
                width: container.frame.width,
                height: 30
            )
        }
        header.addBorder(color: .normal, sides: [.top, .bottom])
        header.backgroundColor = Singleton.lightGrayBackgroundColor
        
        let startLabel = UILabel()
        header.addSubview(startLabel)
        startLabel.font = .preferredFont(forTextStyle: .subheadline)
        startLabel.text = "Earliest Time"
        startLabel.textAlignment = .right
        startLabel.sizeToFit()
        timeWidth = startLabel.frame.width
        startLabel.frame = CGRect(
            x: 15,
            y: 0,
            width: timeWidth,
            height: header.frame.height
        )
        
        let endLabel = UILabel()
        header.addSubview(endLabel)
        endLabel.font = .preferredFont(forTextStyle: .subheadline)
        endLabel.text = "Latest Time"
        endLabel.textAlignment = .right
        endLabel.frame = CGRect(
            x: startLabel.frame.maxX + 15,
            y: 0,
            width: timeWidth,
            height: header.frame.height
        )
        
        let daysLabel = UILabel()
        header.addSubview(daysLabel)
        daysLabel.font = .preferredFont(forTextStyle: .subheadline)
        daysLabel.text = "Days"
        daysLabel.textAlignment = .center
        daysLabel.frame = CGRect(
            x: endLabel.frame.maxX + 15,
            y: 0,
            width: header.frame.width - (endLabel.frame.maxX + 15) - 15,
            height: header.frame.height
        )
        
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 44
        table.separatorInset.left = 15
        table.frame = CGRect(
            x: 0,
            y: header.frame.maxY,
            width: container.frame.width,
            height: container.frame.height - (header.frame.maxY)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if useFilter {
            return filteredSchedules.count
        } else {
            return possibleSchedules.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        var schedule: [ScheduleSection]!
        if useFilter {
            schedule = filteredSchedules[indexPath.row]
        } else {
            schedule = possibleSchedules[indexPath.row]
        }
        var earliest = 2400
        var latest = 0
        var days = [String]()
        for section in schedule {
            for time in section.meetingTimes {
                if time.startTime < earliest {
                    earliest = time.startTime
                }
                if time.endTime > latest {
                    latest = time.endTime
                }
                for day in time.days {
                    if !days.contains(day) {
                        days.append(day)
                    }
                }
            }
        }
        classDays.append(days)
        var daysLabel = ""
        if days.contains("M") {
            daysLabel.append("M, ")
        }
        if days.contains("T") {
            daysLabel.append("T, ")
        }
        if days.contains("W") {
            daysLabel.append("W, ")
        }
        if days.contains("R") {
            daysLabel.append("Th, ")
        }
        if days.contains("F") {
            daysLabel.append("F, ")
        }
        if days.contains("S") {
            daysLabel.append("Sa, ")
        }
        if days.contains("U") {
            daysLabel.append("Su, ")
        }
        daysLabel = daysLabel.trimmingCharacters(in: CharacterSet.init(charactersIn: ", "))
        
        if earliest == 2400 {
            cell.startTime.text = "none"
            earliestTimes.append(2400)
        } else {
            let startRemainder = earliest%100
            let startTimeHour:CGFloat = CGFloat(earliest - startRemainder)/100
            var startLabel = ""
            var startMinutesLabel = ""
            if startRemainder < 10 {
                startMinutesLabel = "0\(startRemainder)"
            } else {
                startMinutesLabel = "\(startRemainder)"
            }
            if startTimeHour == 0 {
                startLabel = "12:\(startMinutesLabel) AM"
            } else if startTimeHour < 12 {
                startLabel = "\(Int(startTimeHour)):\(startMinutesLabel) AM"
            } else if startTimeHour == 12 {
                startLabel = "12:\(startMinutesLabel) PM"
            } else {
                startLabel = "\(Int(startTimeHour) - 12):\(startMinutesLabel) PM"
            }
            cell.startTime.text = startLabel
            earliestTimes.append(startTimeHour + CGFloat(startRemainder)/60)
        }
        
        if latest == 0 {
            cell.endTime.text = "none"
            latestTimes.append(0)
        } else {
            let endRemainder = latest%100
            let endTimeHour:CGFloat = CGFloat(latest - endRemainder)/100
            
            var endLabel = ""
            var endMinutesLabel = ""
            if endRemainder < 10 {
                endMinutesLabel = "0\(endRemainder)"
            } else {
                endMinutesLabel = "\(endRemainder)"
            }
            if endTimeHour == 0 {
                endLabel = "12:\(endMinutesLabel) AM"
            } else if endTimeHour < 12 {
                endLabel = "\(Int(endTimeHour)):\(endMinutesLabel) AM"
            } else if endTimeHour == 12 {
                endLabel = "12:\(endMinutesLabel) PM"
            } else {
                endLabel = "\(Int(endTimeHour) - 12):\(endMinutesLabel) PM"
            }
            cell.endTime.text = endLabel
            latestTimes.append(endTimeHour + CGFloat(endRemainder)/60)
        }
        cell.days.text = daysLabel
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.timeWidth = timeWidth
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = Calendar()
        destination.delegate = delegate
        destination.includeOnline = includeOnline
        destination.includeFull = includeFull
        destination.earliestTime = earliestTimes[indexPath.row]
        destination.latestTime = latestTimes[indexPath.row]
        destination.classDays = classDays[indexPath.row]
        if useFilter {
            destination.classSchedule = filteredSchedules[indexPath.row]
        } else {
            destination.classSchedule = possibleSchedules[indexPath.row]
        }
        navigationController!.pushViewController(destination, animated: true)
    }
    
    func findSections(input: ScheduleSection) -> [Section] {
        var possibleSections = [Section]()
        let subjectIndex = Singleton.schedule[Singleton.semesterIndex].subjects.index(where: {$0.subjectID == input.subjectID})
        let courses = Singleton.schedule[Singleton.semesterIndex].subjects[subjectIndex!].courses
        let courseIndex = courses.index(where: {$0.courseID == input.courseID})
        let sections = courses[courseIndex!].sections
        for section in sections {
            if section.meetingTimes.count == input.meetingTimes.count && !section.meetingTimes.isEmpty {
                if section.isSameTimeAs(comparison: input.meetingTimes) {
                    possibleSections.append(section)
                }
            } else if section.meetingTimes.isEmpty && input.meetingTimes.isEmpty {
                possibleSections.append(section)
            }
        }
        return possibleSections
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    class TableCell: UITableViewCell {
        
        var startTime = UILabel()
        var endTime = UILabel()
        var days = UILabel()
        var cellSize: CGSize!
        var timeWidth: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(startTime)
            startTime.font = .preferredFont(forTextStyle: .body)
            startTime.textAlignment = .right
            contentView.addSubview(endTime)
            endTime.font = .preferredFont(forTextStyle: .body)
            endTime.textAlignment = .right
            contentView.addSubview(days)
            days.font = .preferredFont(forTextStyle: .body)
            days.textAlignment = .center
            days.adjustsFontSizeToFitWidth = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            startTime.frame = CGRect(
                x: 15,
                y: 0,
                width: timeWidth,
                height: cellSize.height
            )
            endTime.frame = CGRect(
                x: startTime.frame.maxX + 15,
                y: 0,
                width: timeWidth,
                height: cellSize.height
            )
            days.frame = CGRect(
                x: endTime.frame.maxX + 15,
                y: 0,
                width: cellSize.width - (endTime.frame.maxX + 15) - 15,
                height: cellSize.height
            )
        }
    }
}
