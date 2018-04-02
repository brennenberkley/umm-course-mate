import Foundation
import UIKit

protocol PlannedCoursesCellProtocol {
    func checkboxValueChanged(row: Int, value: Bool)
}

protocol CreateScheduleProtocol {
    func closedModal(done: Bool)
}

class PlannedCourses: UIViewController, UITableViewDelegate, UITableViewDataSource, PlannedCoursesCellProtocol, CreateScheduleProtocol {
    
    // MARK: - Property Declarations
    var table = UITableView()
    let createButton = UIButton()
    
    var possibleSchedules = [[ScheduleSection]]()
    var conflictingCourses = [ScheduleSection]()
    var cellValues = [Bool]()
    var generateScheduleMessage: String?
    
    var activePlannedCourse: PlannedCourse?
    var selectedRow: Int?
    
    var numberOfPlannedCourses: Int?
    var delegate: AppDelegateProtocol!
    let container = UIView()
    var emptyMessageView = UIView()
    
    var creditsWidth: CGFloat {
        var width:CGFloat = 0
        for course in Singleton.plannedCourses[Singleton.semesterIndex] {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .title3)
            if course.credits == 1 {
                tempLabel.text = "\(course.credits) credit"
            } else {
                tempLabel.text = "\(course.credits) credits"
            }
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        return width
    }
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Planned Courses"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(edit)
        )
        
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + tabBarController!.tabBar.frame.height)
        )
        view.addSubview(container)
        
        let footer = UIView()
        container.addSubview(footer)
        footer.frame = CGRect(
            x: 0,
            y: container.frame.height - 80,
            width: container.frame.width,
            height: 80
        )
        
        let footerDivider = UIView()
        footer.addSubview(footerDivider)
        footerDivider.backgroundColor = Singleton.grayDividerColor
        footerDivider.frame = CGRect(
            x: 0,
            y: 0,
            width: footer.frame.width,
            height: 1/UIScreen.main.scale
        )
        
        footer.addSubview(createButton)
        createButton.frame = CGRect(
            x: 40,
            y: (footer.frame.height - 50) / 2,
            width: footer.frame.width - 80,
            height: 50
        )
        createButton.setTitle("Create Schedule", for: .normal)
        createButton.titleLabel!.adjustsFontSizeToFitWidth = true
        createButton.titleLabel!.font = .preferredFont(forTextStyle: .title2)
        createButton.layer.cornerRadius = 5
        createButton.addTarget(self, action: #selector(generateSchedule), for: .touchUpInside)
        
        container.addSubview(table)
        table.frame = CGRect(
            x: 0,
            y: 0,
            width: container.frame.width,
            height: container.frame.height - footer.frame.height
        )
        
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 60
        table.separatorInset.left = table.rowHeight
        
        for _ in Singleton.plannedCourses[Singleton.semesterIndex] {
            cellValues.append(false)
        }
        checkIfEnabled()
        numberOfPlannedCourses = Singleton.plannedCourses[Singleton.semesterIndex].count
        
        emptyMessageView.frame = CGRect(
            x: 0,
            y: 0,
            width: container.frame.width,
            height: container.frame.height - footer.frame.height
        )
        emptyMessageView.backgroundColor = .white
        let emptyMessage = UILabel()
        if Singleton.schedule.count > 0 {
            emptyMessage.text = "You don't have any planned courses for \(Singleton.schedule[Singleton.semesterIndex].semesterID)"
        } else {
            emptyMessage.text = "You don't have any planned courses"
        }
        
        emptyMessage.font = .preferredFont(forTextStyle: .title1)
        emptyMessage.textAlignment = .center
        emptyMessage.numberOfLines = 0
        emptyMessage.frame = CGRect(
            x: 15,
            y: 50,
            width: container.frame.width - 30,
            height: 200
        )
        emptyMessage.sizeToFit()
        emptyMessage.frame = CGRect(
            x: 15,
            y: 50,
            width: container.frame.width - 30,
            height: emptyMessage.frame.height
        )
        emptyMessageView.addSubview(emptyMessage)
        let emptySubMessage = UILabel()
        emptySubMessage.text = "Go to the catalog to find some"
        emptySubMessage.font = .preferredFont(forTextStyle: .title3)
        emptySubMessage.textAlignment = .center
        emptySubMessage.numberOfLines = 0
        emptySubMessage.frame = CGRect(
            x: 15,
            y: emptyMessage.frame.maxY + 10,
            width: container.frame.width - 30,
            height: 200
        )
        emptySubMessage.sizeToFit()
        emptySubMessage.frame = CGRect(
            x: 15,
            y: emptyMessage.frame.maxY + 10,
            width: container.frame.width - 30,
            height: emptySubMessage.frame.height
        )
        emptyMessageView.addSubview(emptySubMessage)
        
        if !Singleton.onboardingDone {
            let onboarding = Onboarding(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboarding.modalPresentationStyle = .overFullScreen
            navigationController!.present(onboarding, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if table.isEditing {
            done()
        }
        possibleSchedules = [[ScheduleSection]]()
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }
        
        if Singleton.plannedCourses[Singleton.semesterIndex].count > 0 {
            cellValues = []
            for _ in Singleton.plannedCourses[Singleton.semesterIndex] {
                cellValues.append(true)
            }
            table.reloadData()
            checkIfEnabled()
            emptyMessageView.removeFromSuperview()
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            container.addSubview(emptyMessageView)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func closedModal(done: Bool) {
        possibleSchedules = [[ScheduleSection]]()
        conflictingCourses = [ScheduleSection]()
        if done {
            delegate.goToMySchedule()
        }
    }
    
    // MARK: - Table Manangement
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.plannedCourses[Singleton.semesterIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.protocolDelegate = self
        cell.row = indexPath.row
        cell.isChecked = cellValues[indexPath.row]
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        
        let subject = Singleton.plannedCourses[Singleton.semesterIndex][indexPath.row].subjectID
        let number = Singleton.plannedCourses[Singleton.semesterIndex][indexPath.row].courseID
        cell.courseCode.text = "\(subject) \(number)"
        cell.courseTitle.text = Singleton.plannedCourses[Singleton.semesterIndex][indexPath.row].title
        cell.credits.text = "\(Singleton.plannedCourses[Singleton.semesterIndex][indexPath.row].credits) credits"
        cell.creditsWidth = creditsWidth
        cell.isChecked = cellValues[indexPath.row]
        cell.layout()
        cell.shouldIndentWhileEditing = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activePlannedCourse = Singleton.plannedCourses[Singleton.semesterIndex][indexPath.row]
        let campus = Singleton.schedule[Singleton.semesterIndex].subjects
        if let subjectIndex = campus.index(where: {$0.subjectID == activePlannedCourse!.subjectID}) {
            if let courseIndex = campus[subjectIndex].courses.index(where: {$0.courseID == activePlannedCourse!.courseID}) {
                
                numberOfPlannedCourses = Singleton.plannedCourses[Singleton.semesterIndex].count
                selectedRow = indexPath.row
                
                let destination = CourseDetails()
                destination.subjectIndex = subjectIndex
                destination.courseIndex = courseIndex
                navigationController?.pushViewController(destination, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if table.isEditing {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.dataSource!.tableView!(tableView, commit: .delete, forRowAt: indexPath)
        }
        deleteButton.backgroundColor = Singleton.mainAppColor
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            Singleton.plannedCourses[Singleton.semesterIndex].remove(at: indexPath.row)
            cellValues.remove(at: indexPath.row)
            table.beginUpdates()
            table.deleteRows(at: [indexPath], with: .automatic)
            table.endUpdates()
            if table.numberOfRows(inSection: 0) > 0 {
                for cell in table.visibleCells {
                    (cell as! TableCell).row = table.indexPath(for: cell)!.row
                }
            } else {
                container.addSubview(emptyMessageView)
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            checkIfEnabled()
            AppDelegate.savePlannedCourses()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = Singleton.plannedCourses[Singleton.semesterIndex][sourceIndexPath.row]
        Singleton.plannedCourses[Singleton.semesterIndex].remove(at: sourceIndexPath.row)
        Singleton.plannedCourses[Singleton.semesterIndex].insert(movedObject, at: destinationIndexPath.row)
        for i in 0...(table.numberOfRows(inSection: 0) - 1) {
            (table.cellForRow(at: IndexPath(row: i, section: 0)) as! TableCell).row = i
        }
    }
    
    func checkboxValueChanged(row: Int, value: Bool) {
        cellValues[row] = value
        if table.isEditing {
            var enabled = false
            for value in cellValues {
                if value {
                    enabled = true
                }
            }
            navigationItem.leftBarButtonItem?.isEnabled = enabled
        } else {
            checkIfEnabled()
        }
    }
    
    func edit() {
        table.setEditing(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(trash)
        )
        table.isEditing = true
        for cell in table.visibleCells {
            (cell as! TableCell).row = table.indexPath(for: cell)!.row
        }
        createButton.isEnabled = false
        createButton.backgroundColor = Singleton.disabledButtonColor
        for i in 0...(cellValues.count - 1) {
            cellValues[i] = false
            if let cell = table.cellForRow(at: IndexPath(row: i, section: 0)) {
                if (cell as! TableCell).isChecked == true {
                    (cell as! TableCell).toggle()
                }
            }
        }
        navigationItem.leftBarButtonItem!.isEnabled = false
    }
    
    func done() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(edit)
        )
        navigationItem.leftBarButtonItem = .none
        table.isEditing = false
        AppDelegate.savePlannedCourses()
        
        if Singleton.plannedCourses[Singleton.semesterIndex].count > 0 {
            for i in 0...(cellValues.count - 1) {
                cellValues[i] = true
                if let cell = table.cellForRow(at: IndexPath(row: i, section: 0)) {
                    if (cell as! TableCell).isChecked == false {
                        (cell as! TableCell).toggle()
                    }
                }
            }
            table.reloadData()
            createButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            createButton.backgroundColor = Singleton.mainAppColor
        } else {
            container.addSubview(emptyMessageView)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func trash() {
        var values = [Int]()
        for i in 0...(cellValues.count - 1) {
            if cellValues[i] {
                values.append(i)
            }
        }
        for i in 0...(values.count - 1) {
            Singleton.plannedCourses[Singleton.semesterIndex].remove(at: values[i] - i)
            cellValues.remove(at: values[i] - i)
        }
        var indexPaths = [IndexPath]()
        for i in values {
            indexPaths.append([0, i])
        }
        
        table.beginUpdates()
        table.deleteRows(at: indexPaths, with: .automatic)
        table.endUpdates()
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        if table.numberOfRows(inSection: 0) > 0 {
            table.isEditing = true
            for cell in table.visibleCells {
                (cell as! TableCell).row = table.indexPath(for: cell)!.row
            }
        } else {
            done()
        }
    }
    
    func checkIfEnabled() {
        var optionsEnabled = false
        for i in cellValues {
            if i {
                optionsEnabled = true
            }
        }
        createButton.isEnabled = optionsEnabled
        if createButton.isEnabled {
            createButton.backgroundColor = Singleton.mainAppColor
        } else {
            createButton.backgroundColor = Singleton.disabledButtonColor
        }
    }
    
    // MARK: - Schedule Generation
    func generateSchedule() {
        
        var scheduleCourseArray = [ScheduleCourse]()
        /*  Create an array of ScheduleCourses, which omit a lot of the section information and
            combine sections that meet at the same time */
        for i in 0...(cellValues.count - 1) {
            guard cellValues[i] else {
                continue
            }
            let plannedCourse = Singleton.plannedCourses[Singleton.semesterIndex][i]
            let subjects = Singleton.schedule[Singleton.semesterIndex].subjects
            
            // find the actual course in the database referenced by the PlannedCourse
            guard let subjectIndex = subjects.index(where: {$0.subjectID == plannedCourse.subjectID}) else {
                continue
            }
            guard let courseIndex = subjects[subjectIndex].courses.index(where: {$0.courseID == plannedCourse.courseID}) else {
                continue
            }
            let sections = subjects[subjectIndex].courses[courseIndex].sections
            var cancelled = true
            for section in sections {
                if section.status == "A" {
                    cancelled = false
                }
            }
            
            if cancelled {
                let destination = NoSchedules()
                destination.subLabel.text = "All sections of \(plannedCourse.title) have been cancelled"
                destination.conflictingCourses = [ScheduleSection]()
                destination.delegate = self
                let noSchedlesNav = UINavigationController()
                noSchedlesNav.pushViewController(destination, animated: false)
                noSchedlesNav.modalPresentationStyle = .overFullScreen
                noSchedlesNav.navigationBar.tintColor = Singleton.mainAppColor
                navigationController?.present(noSchedlesNav, animated: true, completion: nil)
                return
            }
            let scheduleCourse = ScheduleCourse()
            // create a ScheduleCourse to be displayed in the calendar view later
            scheduleCourse.subjectID = plannedCourse.subjectID
            scheduleCourse.courseID = plannedCourse.courseID
            scheduleCourse.title = plannedCourse.title
            // if there are multiple sections at the same time, only add the time slot once.
            for j in 0...(sections.count - 1) {
                //Check that section is active, otherwise we can ignore it
                guard sections[j].status == "A" else {
                    continue
                }
                var alreadyThere = false
                for section in scheduleCourse.sections {
                    if section.isSameTimeAs(comparison: sections[j].meetingTimes) {
                        alreadyThere = true
                        break
                    }
                }
                guard !alreadyThere else {
                    continue
                }
                let scheduleSection = ScheduleSection()
                scheduleSection.subjectID = scheduleCourse.subjectID
                scheduleSection.courseID = scheduleCourse.courseID
                scheduleSection.title = scheduleCourse.title
                scheduleSection.meetingTimes = sections[j].meetingTimes
                scheduleCourse.sections.append(scheduleSection)
            }
            scheduleCourseArray.append(scheduleCourse)
        }
        
        // Create a possible schedule for each section of the first class in [courseArray]
        for section in scheduleCourseArray[0].sections {
            possibleSchedules.append([section])
        }
        
        var i = 1
        while i <= scheduleCourseArray.count - 1 {
            // Outer loop will run once for each course that needs to be added, each time
            // it will look at the current possible schedules and compare each section of the
            // next course with them to see if they fit
            var possibleSchedulesUpdated = [[ScheduleSection]]()
            var conflictingCourse: ScheduleSection!
            for scheduleSection in scheduleCourseArray[i].sections {
                // cycle through each section of the current course
                for possibleSchedule in possibleSchedules {
                    // cycle through each possible schedule
                    var conflict = false
                    for possibleSection in possibleSchedule {
                        // cycle through each section (course) in the possible schedule
                        if scheduleSection.conflictsWith(comparison: possibleSection.meetingTimes) {
                            // if the section in quesiton conflicts with any of the sections
                            conflict = true
                            conflictingCourse = possibleSection
                        }
                    }
                    if !conflict {
                        // if no conflicts were found, add an entry
                        var newOption = possibleSchedule
                        newOption.append(scheduleSection)
                        possibleSchedulesUpdated.append(newOption)
                    }
                }
            }
            possibleSchedules = possibleSchedulesUpdated
        
        if possibleSchedules.count == 0 {
            conflictingCourses.append(scheduleCourseArray[i].sections.first!)
            conflictingCourses.append(conflictingCourse)
            let destination = NoSchedules()
                destination.delegate = self
                destination.conflictingCourses = conflictingCourses
                destination.subLabel.text = "The following classes meet at the same time"
                let noSchedlesNav = UINavigationController()
                noSchedlesNav.pushViewController(destination, animated: false)
                noSchedlesNav.modalPresentationStyle = .overFullScreen
                noSchedlesNav.navigationBar.tintColor = Singleton.mainAppColor
                navigationController?.present(noSchedlesNav, animated: true, completion: nil)
                return
            }
            i = i + 1
        }
        let destination = FilterSchedules()
        destination.possibleSchedules = possibleSchedules
        destination.conflictingCourses = conflictingCourses
        destination.delegate = self
        let createScheduleNav = UINavigationController()
        createScheduleNav.view.backgroundColor = .white
        createScheduleNav.pushViewController(destination, animated: false)
        createScheduleNav.modalPresentationStyle = .overFullScreen
        createScheduleNav.navigationBar.tintColor = Singleton.mainAppColor
        navigationController?.present(createScheduleNav, animated: true, completion: nil)
    }
    
    class TableCell: UITableViewCell {
        var cellSize: CGSize!
        var courseCode = UILabel()
        var courseTitle = UILabel()
        var credits = UILabel()
        var checkboxContainer = UIButton()
        var checkbox = UIImageView()
        var isChecked = false
        var protocolDelegate: PlannedCoursesCellProtocol!
        var row: Int!
        
        var textHeight: CGFloat!
        var creditsWidth: CGFloat!
        var margin: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        
            contentView.addSubview(checkboxContainer)
            checkboxContainer.addSubview(checkbox)
            contentView.addSubview(courseCode)
            contentView.addSubview(credits)
            contentView.addSubview(courseTitle)
            
            courseCode.font = .preferredFont(forTextStyle: .title3)
            credits.font = .preferredFont(forTextStyle: .title3)
            courseTitle.font = .preferredFont(forTextStyle: .body)
            
            textHeight = courseCode.font.capHeight + courseTitle.font.capHeight

            checkboxContainer.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func layout() {
            checkboxContainer.frame = CGRect(
                x: 0,
                y: 0,
                width: cellSize.height,
                height: cellSize.height
            )
            
            checkbox.frame = CGRect(
                x: (cellSize.height - 22) / 2,
                y: (cellSize.height - 22) / 2,
                width: 22,
                height: 22
            )
            
            if isChecked {
                checkbox.image = #imageLiteral(resourceName: "selected")
            } else {
                checkbox.image = #imageLiteral(resourceName: "unselected")
            }
            
            margin = (cellSize.height - textHeight) / 3

            courseCode.sizeToFit()
            courseCode.frame = CGRect(
                x: checkboxContainer.frame.maxX,
                y: margin - (courseCode.font.ascender - courseCode.font.capHeight),
                width: courseCode.frame.width,
                height: courseCode.frame.height
            )
            credits.sizeToFit()
            credits.frame = CGRect(
                x: cellSize.width - creditsWidth - 52,
                y: margin - (credits.font.ascender - credits.font.capHeight),
                width: creditsWidth,
                height: credits.frame.height
            )
            
            courseTitle.sizeToFit()
            courseTitle.frame = CGRect(
                x: checkboxContainer.frame.maxX,
                y: margin + courseCode.font.capHeight + margin - (courseTitle.font.ascender - courseTitle.font.capHeight),
                width: cellSize.width - checkboxContainer.frame.maxX - 52,
                height: courseTitle.frame.height
            )
        }
        
        func toggle() {
            if isChecked {
                isChecked = false
                checkbox.image = #imageLiteral(resourceName: "unselected")
            } else {
                isChecked = true
                checkbox.image = #imageLiteral(resourceName: "selected")
            }
            protocolDelegate.checkboxValueChanged(row: row, value: isChecked)
        }
    }
}

