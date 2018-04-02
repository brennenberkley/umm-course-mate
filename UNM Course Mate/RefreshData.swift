import UIKit
import CoreData

class RefreshData: NSObject, ScheduleParserDelegateProtocol {
    
    var queue = OperationQueue()
    var schedule = [Semester]()
    
    var currentDocument:String?
    var next1Complete = false
    var temporaryCourses = [String: [Course]]()
    var refreshDataDelegate: AppDelegateProtocol!

    func getClassSchedule() {
        currentDocument = "current"
        
        var currentParser: XMLParser!
        var next1Parser: XMLParser!
        var next2Parser: XMLParser!
        
        let downloadCurrent = BlockOperation(block: {
            let url = URL(string: "https://datastore.unm.edu/schedules/current.xml")!
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 2
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                    self.downloadFailed()
                    return
                }
                guard httpResponse.statusCode == 200  else {
                    self.downloadFailed()
                    return
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                currentParser = XMLParser(contentsOf: url)!
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        })
        
        let downloadNext1 = BlockOperation(block: {
            let url = URL(string: "https://datastore.unm.edu/schedules/next1.xml")!
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 2
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                    self.downloadFailed()
                    return
                }
                guard httpResponse.statusCode == 200  else {
                    self.downloadFailed()
                    return
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                next1Parser = XMLParser(contentsOf: url)!
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        })
        
        let downloadNext2 = BlockOperation(block: {
            let url = URL(string: "https://datastore.unm.edu/schedules/next2.xml")!
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 2
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                    self.downloadFailed()
                    return
                }
                guard httpResponse.statusCode == 200  else {
                    self.downloadFailed()
                    return
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                next2Parser = XMLParser(contentsOf: url)!
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if Singleton.loadStatus == .downloading {
                    self.refreshDataDelegate.updateStatus(status: .processingDownload)
                } else {
                    self.refreshDataDelegate.updateStatus(status: .processingUpdate)
                }
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        })
        
        let parseCurrent = BlockOperation(block: {
            self.currentDocument = "current"
            let parserDelegate = ScheduleParserDelegate()
            parserDelegate.protocolDelegate = self
            parserDelegate.file = "current"
            currentParser.delegate = parserDelegate
            currentParser.parse()
        })
        
        let parseNext1 = BlockOperation(block: {
            self.currentDocument = "next1"
            let parserDelegate = ScheduleParserDelegate()
            parserDelegate.protocolDelegate = self
            parserDelegate.file = "next1"
            next1Parser.delegate = parserDelegate
            next1Parser.parse()
        })
        
        let parseNext2 = BlockOperation(block: {
            self.currentDocument = "next2"
            let parserDelegate = ScheduleParserDelegate()
            parserDelegate.protocolDelegate = self
            parserDelegate.file = "next2"
            next2Parser.delegate = parserDelegate
            next2Parser.parse()
        })
        
        downloadNext1.addDependency(downloadCurrent)
        downloadNext2.addDependency(downloadNext1)
        parseCurrent.addDependency(downloadCurrent)
        parseNext1.addDependency(downloadNext1)
        parseNext1.addDependency(parseCurrent)
        parseNext2.addDependency(downloadNext2)
        parseNext2.addDependency(parseNext1)
        
        downloadCurrent.qualityOfService = .userInitiated
        downloadNext1.qualityOfService = .userInitiated
        downloadNext2.qualityOfService = .userInitiated
        parseCurrent.qualityOfService = .userInitiated
        parseNext1.qualityOfService = .userInitiated
        parseNext2.qualityOfService = .userInitiated
        
        queue.addOperation(downloadCurrent)
        queue.addOperation(downloadNext1)
        queue.addOperation(downloadNext2)
        queue.addOperation(parseCurrent)
        queue.addOperation(parseNext1)
        queue.addOperation(parseNext2)
    }
    
    func downloadFailed() {
        self.queue.cancelAllOperations()
        if Singleton.loadStatus == .downloading {
            refreshDataDelegate.updateStatus(status: .downloadFailed)
        } else {
            refreshDataDelegate.updateStatus(status: .updateFailed)
        }
        UIApplication.shared.endBackgroundTask(Singleton.backgroundUpdateTask)
    }
    
    func doneParsing(file: String) {
        if file == "next2" {
            saveData()
        }
    }
    
    func saveData() {
        //Sort
        for semester in schedule {
            semester.subjects.sort(by: { $0.subjectID < $1.subjectID })
            for subject in semester.subjects {
                subject.courses.sort(by: {$0.courseID < $1.courseID })
                for course in subject.courses {
                    course.sections.sort(by: {$0.sectionID < $1.sectionID })
                    for section in course.sections {
                        for time in section.meetingTimes {
                            if time.startTime == 0 {
                                section.meetingTimes.remove(at: section.meetingTimes.index(of: time)!)
                            }
                        }
                        //Some sections have the same meeting time listed more than once. Fix that:
                        var first = 0
                        while first < section.meetingTimes.count - 1 {
                            var comparison = first + 1
                            while comparison < section.meetingTimes.count {
                                if areSameTime(time1: section.meetingTimes[first], time2: section.meetingTimes[comparison]) {
                                    section.meetingTimes.remove(at: comparison)
                                } else {
                                    comparison = comparison + 1
                                }
                            }
                            first = first + 1
                        }
                    }
                }
            }
        }
        
        // When next1.xml becomes current.xml
        if !Singleton.schedule.isEmpty {
            if Singleton.schedule[0].semesterID != schedule[0].semesterID {
                removeCurrent()
            }
        }
        
        // When the schedule for the next semester is posted (next1.xml becomes non empty)
        if schedule.count >= 2 && Singleton.schedule.count < 2 {
            addNext1()
        }
        if schedule.count >= 3 && Singleton.schedule.count < 3 {
            addNext2()
        }
        
        Singleton.lastUpdate = Date().timeIntervalSinceReferenceDate
        Singleton.schedule = schedule
        
        AppDelegate.saveSchedule()
        Singleton.backgroundUpdateTask = UIBackgroundTaskInvalid
        refreshDataDelegate.updateStatus(status: .upToDate)
    }
    
    func areSameTime(time1: MeetingTime, time2: MeetingTime) -> Bool {
        guard time1.startTime == time2.startTime else {
            return false
        }
        guard time1.endTime == time2.endTime else {
            return false
        }
        guard time1.days == time2.days else {
            return false
        }
        return true
    }
    
    func removeCurrent() {
        Singleton.semesterIndex = 0
        UserDefaults.standard.set(0, forKey: "semesterIndex")
        while Singleton.plannedCourses.count > schedule.count {
            Singleton.plannedCourses.remove(at: 0)
            Singleton.mySchedules.remove(at: 0)
            Singleton.mySchedulesNames.remove(at: 0)
        }
        if Singleton.plannedCourses.isEmpty {
            Singleton.plannedCourses.append([PlannedCourse]())
        }
        if Singleton.mySchedules.isEmpty {
            Singleton.mySchedules.append([[Section]]())
        }
        Singleton.mySchedulesNames.append([String]())
    }
    
    func addNext1() {
        Singleton.semesterIndex = 1
        UserDefaults.standard.set(1, forKey: "semesterIndex")
        if Singleton.schedule.count == 1 {
            if Singleton.mySchedules.count < 2 {
                Singleton.mySchedules.append([[Section]]())
                Singleton.mySchedulesNames.append([String()])
                AppDelegate.saveMySchedules()
            }
            if Singleton.plannedCourses.count < 2 {
                Singleton.plannedCourses.append([PlannedCourse]())
                AppDelegate.savePlannedCourses()
            }
        } else if Singleton.schedule.count == 0 {
            if Singleton.mySchedules.count < 2 {
                Singleton.mySchedules.append([[Section]]())
                Singleton.mySchedules.append([[Section]]())
                Singleton.mySchedulesNames.append([String]())
                Singleton.mySchedulesNames.append([String]())
                AppDelegate.saveMySchedules()
            }
            if Singleton.plannedCourses.count < 2 {
                Singleton.plannedCourses.append([PlannedCourse]())
                Singleton.plannedCourses.append([PlannedCourse]())
                AppDelegate.savePlannedCourses()
            }
        }
    }
    
    func addNext2() {
        Singleton.semesterIndex = 2
        UserDefaults.standard.set(2, forKey: "semesterIndex")
        //counts for mySchedules and plannedCourses will always be 2
        Singleton.mySchedules.append([[Section]]())
        Singleton.mySchedulesNames.append([String()])
        AppDelegate.saveMySchedules()
        Singleton.plannedCourses.append([PlannedCourse]())
        AppDelegate.savePlannedCourses()
    }
    
    func doneParsingSchedule(semester: Semester, file: String) {
        if semester.semesterID != "" {
            schedule.append(semester)
        }
        doneParsing(file: file)
    }
}
