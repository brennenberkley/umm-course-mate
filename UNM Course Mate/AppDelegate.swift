import Foundation
import UIKit
import CoreData

protocol AppDelegateProtocol {
    func updateStatus(status: LoadStatus)
    func retry()
    func goToSearchResults(course: Course)
    func goToSearchResults(subject: Subject)
    func goToMySchedule()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateProtocol {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var catalogNav = UINavigationController()
    var plannedCoursesNav = UINavigationController()
    var mySchedulesNav = UINavigationController()
    var refreshTimeInterval:Double = 30
    
    var tabBarController = UITabBarController()
    var sender: AppDelegateProtocol?
    var operationQueue = OperationQueue()
    static var saveQueue = OperationQueue()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AppDelegate.saveQueue.maxConcurrentOperationCount = 1
        fetchCoreData()
        
        for nav in [catalogNav, plannedCoursesNav, mySchedulesNav] {
            nav.navigationBar.tintColor = Singleton.mainAppColor
        }
        
        let subjectSelection = SubjectSelection()
        subjectSelection.delegate = self
        
        let plannedCourses = PlannedCourses()
        plannedCourses.delegate = self
        
        catalogNav.pushViewController(subjectSelection, animated: false)
        plannedCoursesNav.pushViewController(plannedCourses, animated: false)
        mySchedulesNav.pushViewController(MySchedules(), animated: false)
        
        tabBarController.tabBar.tintColor = Singleton.mainAppColor
        tabBarController.setViewControllers([catalogNav, plannedCoursesNav, mySchedulesNav], animated: true)
        tabBarController.viewControllers![0].tabBarItem = UITabBarItem.init(title: "Catalog", image: #imageLiteral(resourceName: "bookIcon"), tag: 0)
        tabBarController.viewControllers![1].tabBarItem = UITabBarItem.init(title: "Planned Courses", image: #imageLiteral(resourceName: "listIcon"), tag: 1)
        tabBarController.viewControllers![2].tabBarItem = UITabBarItem.init(title: "My Schedules", image: #imageLiteral(resourceName: "calendarIcon"), tag: 2)
        tabBarController.selectedViewController = tabBarController.viewControllers![1]
        
        window = UIWindow()
        window?.rootViewController = tabBarController
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func retry() {
        checkForUpdates()
    }
    
    // MARK: - Data Management
    func fetchCoreData() {
        if let done = UserDefaults.standard.value(forKey: "onboardingDone") {
            Singleton.onboardingDone = done as! Bool
        }
        if let semesterIndex = UserDefaults.standard.value(forKey: "semesterIndex") {
            Singleton.semesterIndex = semesterIndex as! Int
        }
        
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Schedule
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleEntity")
        do {
            let searchResults = try persistentContainer.viewContext.fetch(fetchRequest) as! [ScheduleEntity]
            if !searchResults.isEmpty {
                Singleton.schedule = searchResults.first!.value(forKey: "schedule") as! [Semester]
                Singleton.lastUpdate = searchResults.first!.value(forKey: "lastUpdate") as! TimeInterval
                Singleton.loadStatus = .upToDate
            } else {
                Singleton.loadStatus = .notLoaded
                Singleton.lastUpdate = 0
            }
        } catch {
            print("Error with request: \(error)")
        }
        
        //Planned Couress
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PlannedCoursesEntity")
        do {
            let searchResults = try persistentContainer.viewContext.fetch(fetchRequest) as! [PlannedCoursesEntity]
            if !searchResults.isEmpty {
                Singleton.plannedCourses = searchResults.first!.value(forKey: "plannedCourses") as! [[PlannedCourse]]
            }
        } catch {
            print("Error with request: \(error)")
        }
        
        //My Schedules
        fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MySchedulesEntity")
        do {
            let searchResults = try persistentContainer.viewContext.fetch(fetchRequest) as! [MySchedulesEntity]
            if !searchResults.isEmpty {
                Singleton.mySchedules = searchResults.first!.value(forKey: "mySchedules") as! [[[Section]]]
                Singleton.mySchedulesNames = searchResults.first!.value(forKey: "MySchedulesNames") as! [[String]]
            }
        } catch {
            print("Error with request: \(error)")
        }
        checkForUpdates()
    }
    
    func checkForUpdates() {
        if !Singleton.loadStatus.isSubset(of: .currentlyDownloading) {
            let minutesSinceUpdate = (Date().timeIntervalSinceReferenceDate - Singleton.lastUpdate)/60
            if minutesSinceUpdate > refreshTimeInterval {
                if Singleton.loadStatus.isSubset(of: .loaded) {
                    Singleton.loadStatus = .updating
                } else {
                    Singleton.loadStatus = .downloading
                }
                Singleton.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(withName: "update", expirationHandler: {
                    UIApplication.shared.endBackgroundTask(Singleton.backgroundUpdateTask)
                    Singleton.backgroundUpdateTask = UIBackgroundTaskInvalid
                })
                self.downloadData()
            }
        }
    }
    
    func downloadData() {
        let refreshDataInstance = RefreshData()
        refreshDataInstance.refreshDataDelegate = self
        refreshDataInstance.queue.maxConcurrentOperationCount = 1
        refreshDataInstance.getClassSchedule()
    }
    
    func editPlannedCourses(plannedCourse: PlannedCourse) {
        if let index = Singleton.plannedCourses[Singleton.semesterIndex].index(where: {
            $0.subjectID == plannedCourse.subjectID &&
                $0.courseID == plannedCourse.courseID
        }) {
            Singleton.plannedCourses[Singleton.semesterIndex].remove(at: index)
        } else {
            Singleton.plannedCourses[Singleton.semesterIndex].append(plannedCourse)
        }
    }
    
    func updateStatus(status: LoadStatus) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Singleton.loadStatus = status
            if let subjectSelectionVC = self.catalogNav.viewControllers.first {
                (subjectSelectionVC as! SubjectSelection).updateStatus()
            }
        }
    }
    
    static func saveSchedule() {
        let saveBlock = BlockOperation(block: {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "ScheduleEntity", in: context)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Could not delete schedule: \(error)")
            }
            let object = NSManagedObject(entity: entity!, insertInto: context)
            
            //set the entity values
            object.setValue(Singleton.lastUpdate, forKey: "lastUpdate")
            object.setValue(Singleton.schedule, forKey: "schedule")

            //save the object
            do {
                try context.save()
            } catch {
                print("Could not save schedule: \(error)")
            }
        })
        saveQueue.addOperation(saveBlock)
    }
    
    static func savePlannedCourses() {
        let saveBlock = BlockOperation(block: {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "PlannedCoursesEntity", in: context)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PlannedCoursesEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Could not delete planned courses: \(error)")
            }
            let object = NSManagedObject(entity: entity!, insertInto: context)
            
            //set the entity values
            object.setValue(Singleton.plannedCourses, forKey: "plannedCourses")
            
            //save the object
            do {
                try context.save()
            } catch {
                print("Could not save planned courses: \(error)")
            }
        })
        saveQueue.addOperation(saveBlock)
    }
    
    static func saveMySchedules() {
        let saveBlock = BlockOperation(block: {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "MySchedulesEntity", in: context)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MySchedulesEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Could not delete my schedules: \(error)")
            }
            let object = NSManagedObject(entity: entity!, insertInto: context)
            
            //Make sure schedules and name match
            while Singleton.mySchedules.count > Singleton.mySchedulesNames.count {
                Singleton.mySchedules.removeLast()
            }
            while Singleton.mySchedules.count < Singleton.mySchedulesNames.count {
                Singleton.mySchedulesNames.removeLast()
            }
            
            //set the entity values
            object.setValue(Singleton.mySchedules, forKey: "mySchedules")
            object.setValue(Singleton.mySchedulesNames, forKey: "mySchedulesNames")
            //save the object
            do {
                try context.save()
            } catch {
                print("Could not save my schedules: \(error)")
            }
        })
        saveQueue.addOperation(saveBlock)
    }
    
    func goToSearchResults(subject: Subject) {
        let subjectView = CourseSelection()
        subjectView.subjectIndex = Singleton.schedule[Singleton.semesterIndex].subjects.index(where: {
            $0.subjectID == subject.subjectID
        })
        subjectView.delegate = self
        catalogNav.popToRootViewController(animated: false)
        catalogNav.pushViewController(subjectView, animated: true)
    }
    
    func goToSearchResults(course: Course) {
        let subjectView = CourseSelection()
        subjectView.subjectIndex = Singleton.schedule[Singleton.semesterIndex].subjects.index(where: {
            $0.subjectID == course.subjectID
        })
        let courseView = CourseDetails()
        courseView.subjectIndex = Singleton.schedule[Singleton.semesterIndex].subjects.index(where: {
            $0.subjectID == course.subjectID
        })
        courseView.courseIndex = Singleton.schedule[Singleton.semesterIndex].subjects[courseView.subjectIndex].courses.index(where: {
            $0.courseID == course.courseID
        })
        subjectView.delegate = self
        courseView.delegate = self
        catalogNav.popToRootViewController(animated: false)
        catalogNav.pushViewController(subjectView, animated: false)
        catalogNav.pushViewController(courseView, animated: true)
    }
    
    func goToMySchedule() {
        let scheduleDetails = ScheduleDetails()
        scheduleDetails.scheduleIndex = Singleton.mySchedules[Singleton.semesterIndex].count - 1
        tabBarController.selectedViewController = tabBarController.viewControllers![2]
        mySchedulesNav.popToRootViewController(animated: false)
        mySchedulesNav.pushViewController(scheduleDetails, animated: true)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkForUpdates()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UNM_Course_Mate")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
