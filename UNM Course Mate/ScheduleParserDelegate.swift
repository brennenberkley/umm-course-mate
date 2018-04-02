import Foundation

protocol ScheduleParserDelegateProtocol {
    func doneParsingSchedule(semester: Semester, file: String)
}

class ScheduleParserDelegate: NSObject, XMLParserDelegate {
    
    var semester = Semester()
    
    var file: String!
    var tag:String = ""
    var campus:String = ""
    var subject:Int = 0
    var course:Int = 0
    var section:Int = 0
    var field:Int = 0
    var value:String = ""
    var openCourse:Course?
    var openSection:Section?
    var insideCrossList = false
    var skipCampus = false
    var documentStartTime: TimeInterval!
    var sectionIsOnline = false
    
    var protocolDelegate: ScheduleParserDelegateProtocol!
    
    func parserDidStartDocument(_ parser: XMLParser) {
        documentStartTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        tag = elementName
        if tag == "semester" {
            semester.semesterID = attributeDict["name"]!
        } else if tag == "campus" {
            if attributeDict["code"] == "EA" {
                sectionIsOnline = true
            } else if attributeDict["code"] != "ABQ" {
                skipCampus = true
            }
        }
        guard !skipCampus else {
            return
        }
        switch tag {
        case "subject":
            let code = attributeDict["code"]!
            if semester.subjects.contains(where: {$0.subjectID == code}) {
                subject = semester.subjects.index(where: {$0.subjectID == code})!
            } else {
                subject = semester.subjects.count
                semester.subjects.append(Subject())
                semester.subjects[subject].subjectID = code
                semester.subjects[subject].name = attributeDict["name"]!
            }
        case "course":
            let number = attributeDict["number"]!
            if semester.subjects[subject].courses.contains(where: {$0.courseID == number}) {
                course = semester.subjects[subject].courses.index(where: {$0.courseID == number})!
                openCourse = semester.subjects[subject].courses[course]
            } else {
                course = semester.subjects[subject].courses.count
                semester.subjects[subject].courses.append(Course())
                openCourse = semester.subjects[subject].courses[course]
                openCourse!.title = attributeDict["title"]!
                openCourse!.courseID = attributeDict["number"]!
                openCourse!.subjectID = semester.subjects[subject].subjectID
            }
        case "section":
            guard !insideCrossList else {
                return
            }
            section = openCourse!.sections.count
            openCourse!.sections.append(Section())
            openSection = semester.subjects[subject].courses[course].sections[section]
            openSection!.sectionID = attributeDict["number"]!
            openSection!.crn = attributeDict["crn"]!
            openSection!.status = attributeDict["status"]!
            openSection!.courseID = openCourse!.courseID
            openSection!.subjectID = semester.subjects[subject].subjectID
            openSection!.courseTitle = openCourse!.title
            openSection!.isOnline = sectionIsOnline
        case "enrollment":
            openSection!.enrollmentMax = (attributeDict["max"]! as NSString).integerValue
        case "waitlist":
            openSection!.waitlistMax = (attributeDict["max"]! as NSString).integerValue
        case "instructor":
            openSection!.instructors.append(Instructor())
            if attributeDict["primary"] == "y" {
                openSection!.instructors.last!.primary = true
            } else {
                openSection!.instructors.last!.primary = false
            }
        case "meeting-time":
            openSection!.meetingTimes.append(MeetingTime())
        case "days":
            openSection!.meetingTimes.last?.days = [String]()
        case "bldg":
            openSection!.meetingTimes.last?.buildingCode = attributeDict["code"]!
        case "crosslists":
            insideCrossList = true
        default: return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !skipCampus {
            value.append(string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "campus" {
            skipCampus = false
            sectionIsOnline = false
        }
        guard !skipCampus else {
            return
        }
        switch tag {
        case "catalog-description":
            openCourse!.catalogDescription = value
        case "enrollment":
            openCourse!.sections[section].enrollment = (value as NSString).integerValue
        case "waitlist":
            openCourse!.sections[section].waitlist = (value as NSString).integerValue
        case "credits":
            openCourse!.sections[section].credits = (value as NSString).integerValue
        case "fees":
            openCourse!.sections[section].fees = (value as NSString).integerValue
        case "first":
            openCourse!.sections[section].instructors.last!.first = value
        case "last":
            openCourse!.sections[section].instructors.last!.last = value
        case "start-date":
            openCourse!.sections[section].meetingTimes.last!.startDate = value
        case "end-date":
            openCourse!.sections[section].meetingTimes.last!.endDate = value
        case "day":
            openCourse!.sections[section].meetingTimes.last!.days.append(value)
        case "start-time":
            openCourse!.sections[section].meetingTimes.last!.startTime = (value as NSString).integerValue
        case "end-time":
            openCourse!.sections[section].meetingTimes.last!.endTime = (value as NSString).integerValue
        case "bldg":
            openCourse!.sections[section].meetingTimes.last!.building = value
        case "room":
            openCourse!.sections[section].meetingTimes.last!.room = value
        default: break
        }
        
        value = ""
        tag = ""
        if elementName == "crosslists" {
            insideCrossList = false
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.protocolDelegate.doneParsingSchedule(semester: self.semester, file: self.file)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("ERROR: \(parseError)")
    }
}
