import Foundation

class ScheduleSection: NSObject {
    var subjectID: String = ""
    var courseID: String = ""
    var title:String = ""
    var meetingTimes = [MeetingTime]()
    
    func isSameTimeAs(comparison: [MeetingTime]) -> Bool {
        if meetingTimes.count != comparison.count {
            return false
        } else if meetingTimes.count > 0 {
            for i in 0...(meetingTimes.count - 1) {
                if !meetingTimes[i].isEquivalentTo(comparison: comparison[i]) {
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
    
    func conflictsWith(comparison: [MeetingTime]) -> Bool {
        for time1 in comparison {
            for time2 in meetingTimes {
                for day in time1.days {
                    if time2.days.contains(day) {
                        // at least one day conflicts
                        if !(time1.endTime < time2.startTime || time2.endTime < time1.startTime) {
                            return true // !(one class ends before the other starts)
                        }
                    }
                }
            }
        }
        return false
    }
}
