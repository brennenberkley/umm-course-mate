import Foundation
import UIKit

class CourseDetails: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Property Declarations
    var delegate: AppDelegateProtocol!
    var courseTitle = UILabel()
    var credits = UILabel()
    var scrollView = UIScrollView()
    var courseDescription = UILabel()
    var plannedCoursesButton = UIButton()
    var sectionsTitle = UILabel()
    var table = UITableView()
    
    var subjectIndex:Int!
    var courseIndex:Int!
    
    var activeSubject:Subject!
    var activeCourse:Course!
    
    var codeWidth:CGFloat {
        var width:CGFloat = 0
        for section in activeCourse.sections {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .body)
            tempLabel.text = section.sectionID
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        return width
    }
    
    var onlineWidth:CGFloat {
        var width:CGFloat = 0
        for section in activeCourse.sections {
            if section.isOnline {
                let tempLabel = UILabel()
                tempLabel.font = .preferredFont(forTextStyle: .body)
                tempLabel.text = "online"
                tempLabel.sizeToFit()
                width = tempLabel.frame.width
            }
        }
        return width
    }
    
    var enrollmentWidth:CGFloat {
        var width:CGFloat = 0
        for section in activeCourse.sections {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .body)
            if section.status == "A" {
                if section.enrollmentMax == 0 {
                    tempLabel.text = "Full"
                } else if section.enrollment >= section.enrollmentMax {
                    tempLabel.text = "Full"
                } else {
                    tempLabel.text = "\(section.enrollment)/\(section.enrollmentMax)"
                }
            } else {
                tempLabel.text = "Cancelled"
            }
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        return width
    }
    
    let margins:CGFloat = 10 + 15 + 30 + 30
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(search)
        )
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + tabBarController!.tabBar.frame.height)
        )
        view.addSubview(container)
        
        activeSubject = Singleton.schedule[Singleton.semesterIndex].subjects[subjectIndex]
        activeCourse = activeSubject.courses[courseIndex]
        
        navigationItem.title = "\(activeSubject.subjectID) \(activeCourse.courseID)"
        
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 44
        table.separatorInset.left = 10
        
        //MARK: Layout
        
        courseTitle.font = .preferredFont(forTextStyle: .title1)
        courseTitle.text = activeCourse.title
        courseTitle.frame = CGRect(
            x: 10,
            y: 10,
            width: container.frame.width - 20,
            height: container.frame.height
        )
        courseTitle.numberOfLines = 0
        if UIScreen.main.bounds.height <= 568 {
            courseTitle.numberOfLines = 1
            courseTitle.adjustsFontSizeToFitWidth = true
        }
        courseTitle.sizeToFit()
        
        if let firstSection = activeCourse.sections.first {
            if firstSection.credits == 1 {
                credits.text = "\(firstSection.credits) credit"
            } else {
                credits.text = "\(firstSection.credits) credits"
            }
        }
        credits.font = .preferredFont(forTextStyle: .title2)
        credits.textColor = Singleton.mainAppColor
        credits.sizeToFit()
        
        courseDescription.text = activeCourse.catalogDescription
        courseDescription.font = .preferredFont(forTextStyle: .body)
        courseDescription.numberOfLines = 0
        courseDescription.frame = CGRect(
            x: 30,
            y: 0,
            width: container.frame.width - 40,
            height: 0
        )
        courseDescription.sizeToFit()
        
        plannedCoursesButton.setTitle("Add to planned courses", for: .normal)
        plannedCoursesButton.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        plannedCoursesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        plannedCoursesButton.setTitleColor(.white, for: .normal)
        plannedCoursesButton.backgroundColor = Singleton.mainAppColor
        plannedCoursesButton.addTarget(self, action: #selector(addToPlannedCourses), for: .touchUpInside)
        plannedCoursesButton.sizeToFit()
        plannedCoursesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        plannedCoursesButton.frame = CGRect(
            x: 40,
            y: scrollView.frame.maxY + 30,
            width: container.frame.width - 80,
            height: 40
        )
        plannedCoursesButton.layer.cornerRadius = 5
        
        sectionsTitle.text = "Sections"
        sectionsTitle.font = .preferredFont(forTextStyle: .title2)
        sectionsTitle.sizeToFit()
        
        // Calculate Heights
        var scrollViewHeight:CGFloat = 0
        var tableHeight:CGFloat = 0
        let otherHeight = courseTitle.frame.height + credits.frame.height + plannedCoursesButton.frame.height + sectionsTitle.frame.height + margins
        let totalHeight = courseDescription.frame.height + otherHeight + table.rowHeight*CGFloat(activeCourse.sections.count)
        if totalHeight < container.frame.height {
            scrollViewHeight = courseDescription.frame.height
            tableHeight = container.frame.height - otherHeight - scrollViewHeight
        } else {
            if activeCourse.sections.count < 3 {
                tableHeight = table.rowHeight * (CGFloat(activeCourse.sections.count) + 0.5)
            } else {
                tableHeight = table.rowHeight * 3.5
            }
            scrollViewHeight = container.frame.height - otherHeight - tableHeight
            if scrollViewHeight > courseDescription.frame.height {
                scrollViewHeight = courseDescription.frame.height
                tableHeight = container.frame.height - otherHeight - scrollViewHeight
            }
        }
        
        // Adjust Positions
        courseTitle.frame = CGRect(
            x: 10,
            y: 10,
            width: container.frame.width - 20,
            height: courseTitle.frame.height
        )

        credits.frame = CGRect(
            x: 30,
            y: courseTitle.frame.maxY,
            width: container.frame.width - 40,
            height: credits.frame.height
        )
        
        scrollView.frame = CGRect(
            x: 0,
            y: credits.frame.maxY + 15,
            width: container.frame.width,
            height: scrollViewHeight
        )
        
        scrollView.contentSize = CGSize(
            width: container.frame.width,
            height: courseDescription.frame.height
        )
        scrollView.addSubview(courseDescription)
        
        if container.frame.width > 320 {
            plannedCoursesButton.frame = CGRect(
                x: 40,
                y: scrollView.frame.maxY + 30,
                width: container.frame.width - 80,
                height: plannedCoursesButton.frame.height
            )
        } else {
            plannedCoursesButton.frame = CGRect(
                x: 20,
                y: scrollView.frame.maxY + 30,
                width: container.frame.width - 40,
                height: plannedCoursesButton.frame.height
            )
        }
        
        sectionsTitle.frame = CGRect(
            x: 10,
            y: plannedCoursesButton.frame.maxY + 30,
            width: sectionsTitle.frame.width,
            height: sectionsTitle.frame.height
        )
        
        table.frame = CGRect(
            x: 0,
            y: sectionsTitle.frame.maxY,
            width: container.frame.width,
            height: tableHeight
        )
        table.addBorder(color: .normal, sides: [.top])
        
        container.addSubview(courseTitle)
        container.addSubview(credits)
        container.addSubview(scrollView)
        container.addSubview(plannedCoursesButton)
        container.addSubview(sectionsTitle)
        container.addSubview(table)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }

        if checkIfPlannedCourse() {
            plannedCoursesButton.setTitle("Remove from planned courses", for: .normal)
        } else {
            plannedCoursesButton.setTitle("Add to planned courses", for: .normal)
        }
    }
    
    func checkIfPlannedCourse() -> Bool {
        let planned = PlannedCourse()
        planned.subjectID = activeSubject.subjectID
        planned.courseID = activeCourse.courseID
        planned.title = activeCourse.title
        if let first = activeCourse.sections.first {
            planned.credits = first.credits
        } else {
            planned.credits = 0
        }
        
        if let _ = Singleton.plannedCourses[Singleton.semesterIndex].index(where: {
                $0.subjectID == planned.subjectID &&
                $0.courseID == planned.courseID
        }) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeCourse.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.codeWidth = codeWidth
        cell.onlineWidth = onlineWidth
        cell.isOnline = activeCourse.sections[indexPath.row].isOnline
        cell.enrollmentWidth = enrollmentWidth
        cell.code.text = "\(activeCourse.sections[indexPath.row].sectionID)"
        if let teacher = activeCourse.sections[indexPath.row].instructors.first {
            cell.teacher.text = "\(teacher.first) \(teacher.last)"
            cell.teacher.textColor = .black
        } else {
            cell.teacher.text = "Instructor TBA"
            cell.teacher.textColor = Singleton.lightGrayTextColor
        }
        
        if activeCourse.sections[indexPath.row].status == "A" {
        let enrolled = activeCourse.sections[indexPath.row].enrollment
        let max = activeCourse.sections[indexPath.row].enrollmentMax
        if max > 0 {
            if enrolled >= max {
                cell.enrollment.textColor = Singleton.mainAppColor
                cell.isFull = true
            } else if CGFloat(enrolled)/CGFloat(max) > 0.9 {
                cell.enrollment.textColor = Singleton.mainAppColor
                cell.isFull = false
            } else {
                cell.enrollment.textColor = .black
                cell.isFull = false
            }
        } else {
            cell.enrollment.textColor = Singleton.mainAppColor
            cell.isFull = false
        }
        if cell.isFull {
            cell.enrollment.text = "Full"
        } else {
            cell.enrollment.text = "\(enrolled)/\(max)"
        }
        } else {
            cell.enrollment.text = "Cancelled"
            cell.enrollment.textColor = Singleton.mainAppColor
        }
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = SectionDetails()
        destination.delegate = delegate
        destination.section = activeCourse.sections[indexPath.row]
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func search() {
        let searchView = Search()
        searchView.delegate = delegate
        searchView.modalPresentationStyle = .popover
        navigationController?.present(searchView, animated: false, completion: nil)
    }
    
    // MARK: - Data Management
    func addToPlannedCourses() {
        let planned = PlannedCourse()
        planned.subjectID = activeSubject.subjectID
        planned.courseID = activeCourse.courseID
        planned.title = activeCourse.title
        if let first = activeCourse.sections.first {
            planned.credits = first.credits
        } else {
            planned.credits = 0
        }
        
        if let index = Singleton.plannedCourses[Singleton.semesterIndex].index(where: {
            $0.subjectID == planned.subjectID &&
            $0.courseID == planned.courseID
        }) {
            Singleton.plannedCourses[Singleton.semesterIndex].remove(at: index)
            plannedCoursesButton.setTitle("Add to planned courses", for: .normal)
        } else {
            Singleton.plannedCourses[Singleton.semesterIndex].append(planned)
            plannedCoursesButton.setTitle("Remove from planned courses", for: .normal)
        }
        AppDelegate.savePlannedCourses()
    }
    
    class TableCell: UITableViewCell {
        
        var code = UILabel()
        var teacher = UILabel()
        var enrollment = UILabel()
        var online = UILabel()
        var full = UILabel()
        
        var cellSize: CGSize!
        var codeWidth: CGFloat!
        var onlineWidth: CGFloat!
        var enrollmentWidth: CGFloat!
        var isFull = false
        var isOnline = false
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        
            code.font = .preferredFont(forTextStyle: .body)
            contentView.addSubview(code)
            
            enrollment.font = .preferredFont(forTextStyle: .body)
            enrollment.textAlignment = .center
            enrollment.adjustsFontSizeToFitWidth = true
            contentView.addSubview(enrollment)
            
            online.font = .preferredFont(forTextStyle: .body)
            online.textAlignment = .center
            online.adjustsFontSizeToFitWidth = true
            online.textColor = Singleton.mainAppColor
            contentView.addSubview(online)
            
            teacher.font = .preferredFont(forTextStyle: .body)
            teacher.adjustsFontSizeToFitWidth = true
            teacher.minimumScaleFactor = 0.8
            contentView.addSubview(teacher)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            code.frame = CGRect(
                x: 10,
                y: 0,
                width: codeWidth,
                height: cellSize.height
            )
            
            var teacherWidth: CGFloat!
            if onlineWidth == 0 {
                teacherWidth = cellSize.width - (40 + codeWidth + enrollmentWidth)
            } else {
                teacherWidth = cellSize.width - (50 + codeWidth + enrollmentWidth + onlineWidth)
            }
            
            teacher.frame = CGRect(
                x: code.frame.maxX + 10,
                y: 0,
                width: teacherWidth,
                height: cellSize.height
            )
            
            if isOnline {
                online.text = "online"
            } else {
                online.text = ""
            }
            if onlineWidth != 0 {
                online.frame = CGRect(
                    x: teacher.frame.maxX + 10,
                    y: 0,
                    width: onlineWidth,
                    height: cellSize.height
                )
                
                enrollment.frame = CGRect(
                    x: online.frame.maxX + 10,
                    y: 0,
                    width: enrollmentWidth,
                    height: cellSize.height
                )
            } else {
                online.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: 0,
                    height: 0
                )
                
                enrollment.frame = CGRect(
                    x: teacher.frame.maxX + 10,
                    y: 0,
                    width: enrollmentWidth,
                    height: cellSize.height
                )
            }
        }
    }
}
