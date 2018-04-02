import Foundation

class Section:NSObject {
    var sectionID:String = ""
    var crn:String = ""
    var status:String = ""
    var enrollment:Int = 0
    var enrollmentMax:Int = 0
    var waitlist:Int = 0
    var waitlistMax:Int = 0
    var credits:Int = 0
    var fees:Int = 0
    var instructors = [Instructor]()
    var meetingTimes = [MeetingTime]()
    var courseID:String = ""
    var subjectID:String = ""
    var courseTitle:String = ""
    var isOnline = false
    
/* Status codes:
     A - Active
     C - Cancelled
     I - Inactive
     M - Cancelled with message
     R - Reserved
     S - Cancelled/Rescheduled
     T - Cancelled/Rescheduled with message
    
     Only A, C, and S are used.
 */
 
    override init() {}
    
    required init?(coder aDecoder: NSCoder) {
        self.sectionID = aDecoder.decodeObject(forKey: "sectionID") as! String
        self.crn = aDecoder.decodeObject(forKey: "crn") as! String
        self.status = aDecoder.decodeObject(forKey: "status") as! String
        self.enrollment = aDecoder.decodeInteger(forKey: "enrollment")
        self.enrollmentMax = aDecoder.decodeInteger(forKey: "enrollmentMax")
        self.waitlist = aDecoder.decodeInteger(forKey: "waitlist")
        self.waitlistMax = aDecoder.decodeInteger(forKey: "waitlistMax")
        self.credits = aDecoder.decodeInteger(forKey: "credits")
        self.fees = aDecoder.decodeInteger(forKey: "fees")
        self.instructors = aDecoder.decodeObject(forKey: "instructors") as! [Instructor]
        self.meetingTimes = aDecoder.decodeObject(forKey: "meetingTimes") as! [MeetingTime]
        self.courseID = aDecoder.decodeObject(forKey: "courseID") as! String
        self.subjectID = aDecoder.decodeObject(forKey: "subjectID") as! String
        self.courseTitle = aDecoder.decodeObject(forKey: "courseTitle") as! String
        self.isOnline = aDecoder.decodeBool(forKey: "isOnline")
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(sectionID, forKey: "sectionID")
        aCoder.encode(crn, forKey: "crn")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(enrollment, forKey: "enrollment")
        aCoder.encode(enrollmentMax, forKey: "enrollmentMax")
        aCoder.encode(waitlist, forKey: "waitlist")
        aCoder.encode(waitlistMax, forKey: "waitlistMax")
        aCoder.encode(credits, forKey: "credits")
        aCoder.encode(fees, forKey: "fees")
        aCoder.encode(instructors, forKey: "instructors")
        aCoder.encode(meetingTimes, forKey: "meetingTimes")
        aCoder.encode(courseID, forKey: "courseID")
        aCoder.encode(subjectID, forKey: "subjectID")
        aCoder.encode(courseTitle, forKey: "courseTitle")
        aCoder.encode(isOnline, forKey: "isOnline")
    }
    
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
}
