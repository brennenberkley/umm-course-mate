import Foundation
import UIKit
import EventKit

class ExportSchedule: UIViewController {
    
    var calendars: [EKCalendar]!
    var scheduleIndex: Int!
    var calendarIndex: Int!
    var newCalendarName: String?
    var newCalendarColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Confirm"
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        let scheduleLabel = UILabel()
        container.addSubview(scheduleLabel)
        scheduleLabel.font = .preferredFont(forTextStyle: .body)
        scheduleLabel.textColor = Singleton.mainAppColor
        scheduleLabel.text = "schedule"
        scheduleLabel.sizeToFit()
        scheduleLabel.frame = CGRect(
            x: 20,
            y: 20,
            width: container.frame.width - 40,
            height: scheduleLabel.frame.height
        )
        
        let schedule = UILabel()
        container.addSubview(schedule)
        schedule.font = .preferredFont(forTextStyle: .title1)
        schedule.text = Singleton.mySchedulesNames[Singleton.semesterIndex][scheduleIndex]
        schedule.sizeToFit()
        schedule.adjustsFontSizeToFitWidth = true
        schedule.minimumScaleFactor = 0.7
        schedule.frame = CGRect(
            x: 40,
            y: scheduleLabel.frame.maxY + 5,
            width: container.frame.width - 50,
            height: schedule.frame.height
        )
        
        let calendarLabel = UILabel()
        container.addSubview(calendarLabel)
        calendarLabel.font = .preferredFont(forTextStyle: .body)
        calendarLabel.textColor = Singleton.mainAppColor
        calendarLabel.text = "calendar"
        calendarLabel.sizeToFit()
        calendarLabel.frame = CGRect(
            x: 20,
            y: schedule.frame.maxY + 20,
            width: container.frame.width - 40,
            height: calendarLabel.frame.height
        )
        
        let calendar = UILabel()
        container.addSubview(calendar)
        calendar.font = .preferredFont(forTextStyle: .title1)
        if let newName = newCalendarName {
            calendar.text = newName
        } else {
            calendar.text = calendars[calendarIndex].title
        }
        calendar.sizeToFit()
        let color = UIView()
        color.frame = CGRect(
            x: 40,
            y: calendarLabel.frame.maxY + 5 + (calendar.font.ascender - calendar.font.capHeight),
            width: calendar.font.capHeight,
            height: calendar.font.capHeight
        )
        color.layer.cornerRadius = 3
        if let newColor = newCalendarColor {
            color.backgroundColor = newColor
        } else {
            color.backgroundColor = UIColor(cgColor: calendars[calendarIndex].cgColor)
        }
        container.addSubview(color)
        
        calendar.adjustsFontSizeToFitWidth = true
        calendar.minimumScaleFactor = 0.7
        calendar.frame = CGRect(
            x: color.frame.maxX + 10,
            y: calendarLabel.frame.maxY + 5,
            width: container.frame.width - (color.frame.maxX + 10) - 10,
            height: calendar.frame.height
        )
        
        let exportButton = UIButton()
        container.addSubview(exportButton)
        exportButton.frame = CGRect(
            x: 40,
            y: calendar.frame.maxY + 40,
            width: container.frame.width - 80,
            height: 50
        )
        exportButton.backgroundColor = Singleton.mainAppColor
        exportButton.setTitle("Export to Calendar", for: .normal)
        exportButton.titleLabel?.adjustsFontSizeToFitWidth = true
        exportButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        exportButton.layer.cornerRadius = 5
        exportButton.addTarget(self, action: #selector(export), for: .touchUpInside)
    }
    
    func export() {
        let store = EKEventStore()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm yyyy-MM-dd"
        
        var calendar: EKCalendar
        
        if let newName = newCalendarName {
            let newCalendar = EKCalendar(for: .event, eventStore: store)
            newCalendar.title = newName
            newCalendar.source = store.defaultCalendarForNewEvents.source
            newCalendar.cgColor = newCalendarColor!.cgColor
            do {
                try store.saveCalendar(newCalendar, commit: true)
            } catch {
                print("error \(error)")
            }
            calendar = newCalendar
        } else {
            calendar = calendars[calendarIndex]
        }

        for section in Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex] {
            for meetingTime in section.meetingTimes {
                let event = EKEvent(eventStore: store)
                event.title = section.courseTitle
                
                var days = [EKRecurrenceDayOfWeek]()
                var dayOffset = 0
                // Filter schedules
                if meetingTime.days.contains("U") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 1)!))
                    dayOffset = 6
                }
                if meetingTime.days.contains("S") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 7)!))
                    dayOffset = 5
                }
                if meetingTime.days.contains("F") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 6)!))
                    dayOffset = 4
                }
                if meetingTime.days.contains("R") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 5)!))
                    dayOffset = 3
                }
                if meetingTime.days.contains("W") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 4)!))
                    dayOffset = 2
                }
                if meetingTime.days.contains("T") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 3)!))
                    dayOffset = 1
                }
                if meetingTime.days.contains("M") {
                    days.append(EKRecurrenceDayOfWeek.init(EKWeekday(rawValue: 2)!))
                    dayOffset = 0
                }
                
                let start = meetingTime.startDate.components(separatedBy: "-")
                let day = Int(start[2])! + dayOffset
                if meetingTime.startTime < 1000 {
                    event.startDate = formatter.date(from: "0\(meetingTime.startTime) \(start[0])-\(start[1])-\(day)")!
                } else {
                    event.startDate = formatter.date(from: "\(meetingTime.startTime) \(start[0])-\(start[1])-\(day)")!
                }
                if meetingTime.endTime < 1000 {
                    event.endDate = formatter.date(from: "0\(meetingTime.endTime) \(start[0])-\(start[1])-\(day)")!
                } else {
                    event.endDate = formatter.date(from: "\(meetingTime.endTime) \(start[0])-\(start[1])-\(day)")!
                }
                event.recurrenceRules = [
                    .init(
                        recurrenceWith: .weekly,
                        interval: 1,
                        daysOfTheWeek: days,
                        daysOfTheMonth: nil,
                        monthsOfTheYear: nil,
                        weeksOfTheYear: nil,
                        daysOfTheYear: nil,
                        setPositions: nil,
                        end: EKRecurrenceEnd.init(end: formatter.date(from: "0000 \(meetingTime.endDate)")!)
                    )
                ]
                event.location = "\(meetingTime.buildingCode) \(meetingTime.room)"
                event.timeZone = TimeZone.init(identifier: "America/Denver")
                event.calendar = calendar
                do {
                    try store.save(event, span: .thisEvent)
                } catch {
                    print("could not save event")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
