import Foundation
import UIKit

class Singleton {
    static var semesterIndex = 0
    static var schedule = [Semester]()
    static var plannedCourses: [[PlannedCourse]] = [[PlannedCourse]()]
    static var mySchedules: [[[Section]]] = [[[Section]]()] //outer braces are for semester
    static var mySchedulesNames: [[String]] = [ [String]()]
    static var lastUpdate:TimeInterval = 0 // seconds since last download from server
    static var loadStatus = LoadStatus()
    static var onboardingDone = false
    static var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    static var mainAppColor = UIColor(red: 0.9, green: 0, blue: 0, alpha: 1)
    static var lightGrayTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    static var darkGrayTextColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static var grayBarColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    static var disabledButtonColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    static var grayDividerColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    static var lightGrayDividerColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
    static var lightGrayBackgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
}
