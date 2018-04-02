import Foundation
import UIKit
import EventKit

protocol AddClassProtocol {
    func addClass(section: Section)
}

class ScheduleDetails: UIViewController, UITableViewDelegate, UITableViewDataSource, AddClassProtocol {
    
    var table = UITableView()
    var scheduleIndex: Int!
    var crnWidth: CGFloat {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.text = "00000"
        label.sizeToFit()
        return label.frame.width
    }
    
    var courseCodeWidth: CGFloat {
        var width:CGFloat = 0
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        for section in Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex] {
            label.text = "\(section.subjectID)-\(section.courseID)"
            label.sizeToFit()
            if label.frame.width > width {
                width = label.frame.width
            }
            label.text = "\(section.credits) credits"
            label.sizeToFit()
            if label.frame.width > width {
                width = label.frame.width
            }
        }
        return width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //navigationItem.title = Singleton.mySchedulesNames[Singleton.semesterIndex][scheduleIndex]
        let title = UIButton()
        title.backgroundColor = Singleton.lightGrayBackgroundColor
        title.setTitle(Singleton.mySchedulesNames[Singleton.semesterIndex][scheduleIndex], for: .normal)
        title.titleLabel!.font = .preferredFont(forTextStyle: .headline)
        title.setTitleColor(.black, for: .normal)
        title.addTarget(self, action: #selector(renameSchedule), for: .touchUpInside)
        title.sizeToFit()
        title.frame = CGRect(
            x: 0,
            y: 0,
            width: title.frame.width,
            height: navigationController!.navigationBar.frame.height
        )
        navigationItem.titleView = title

    
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            image: #imageLiteral(resourceName: "calendarPlusIcon"),
            style: .plain,
            target: self,
            action: #selector(export)
        )
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + tabBarController!.tabBar.frame.height)
        )
        view.addSubview(container)
        
        let header = UIView()
        container.addSubview(header)
        header.frame = CGRect(
            x: 0,
            y: 0,
            width: container.frame.width,
            height: 30
        )
        header.addBorder(color: .normal, sides: [.bottom])
        header.backgroundColor = Singleton.lightGrayBackgroundColor
        
        let crnLabel = UILabel()
        header.addSubview(crnLabel)
        crnLabel.font = .preferredFont(forTextStyle: .subheadline)
        crnLabel.text = "CRN"
        crnLabel.textAlignment = .center
        crnLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: crnWidth,
            height: header.frame.height
        )
        
        let detailsLabel = UILabel()
        header.addSubview(detailsLabel)
        detailsLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailsLabel.text = "Course Details"
        detailsLabel.textAlignment = .center
        detailsLabel.frame = CGRect(
            x: crnLabel.frame.maxX + 10,
            y: 0,
            width: header.frame.width - crnLabel.frame.maxX - 20,
            height: header.frame.height
        )
        
        container.addSubview(table)
        table.frame = CGRect(
            x: 0,
            y: header.frame.maxY,
            width: container.frame.width,
            height: container.frame.height - header.frame.maxY
        )
        table.dataSource = self
        table.delegate = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.register(AddClassTableCell.self, forCellReuseIdentifier: "add")
        table.rowHeight = table.frame.width * 0.3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
        table.reloadData()
    }

    func renameSchedule() {
        let renameMenu = UIAlertController.init(title: "Rename Schedule", message: "Enter a new name for this schedule", preferredStyle: .alert)
        renameMenu.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = Singleton.mySchedulesNames[Singleton.semesterIndex][self.scheduleIndex]
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
        })
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            renameMenu.dismiss(animated: true, completion: nil)
        })
        
        let saveButton = UIAlertAction.init(title: "Save", style: .default, handler: { (UIAlertAction) -> Void in
            renameMenu.dismiss(animated: true, completion: nil)
            let name = renameMenu.textFields!.first!.text
            if name != "" {
                Singleton.mySchedulesNames[Singleton.semesterIndex][self.scheduleIndex] = name!
                AppDelegate.saveMySchedules()
                self.dismiss(animated: true, completion: nil)
                (self.navigationItem.titleView as! UIButton).setTitle(name!, for: .normal)
                self.navigationItem.titleView!.sizeToFit()
                self.navigationItem.titleView!.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: self.navigationItem.titleView!.frame.width,
                    height: self.navigationController!.navigationBar.frame.height
                )
            }
        })
        
        renameMenu.addAction(cancel)
        renameMenu.addAction(saveButton)
        renameMenu.preferredAction = saveButton
        
        navigationController!.present(renameMenu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCell
            cell.section = Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex][indexPath.row]
            cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
            cell.crnWidth = crnWidth
            cell.courseCodeWidth = courseCodeWidth
            cell.layout()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add") as! AddClassTableCell
            cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
            cell.layout()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].count {
            let destination = SectionDetails()
            destination.section = Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex][indexPath.row]
            destination.showSearch = false
            navigationController?.pushViewController(destination, animated: true)
        } else {
            let addClassNav = UINavigationController()
            let addClassSubjects = AddClassSubjects()
            addClassSubjects.delegate = self
            addClassNav.pushViewController(addClassSubjects, animated: false)
            addClassNav.modalPresentationStyle = .overFullScreen
            addClassNav.navigationBar.tintColor = Singleton.mainAppColor
            navigationController?.present(addClassNav, animated: true, completion: nil)
            table.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].remove(at: indexPath.row)
            table.beginUpdates()
            table.deleteRows(at: [indexPath], with: .automatic)
            table.endUpdates()
            AppDelegate.saveMySchedules()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.dataSource!.tableView!(tableView, commit: .delete, forRowAt: indexPath)
        }
        deleteButton.backgroundColor = Singleton.mainAppColor
        return [deleteButton]
    }
    
    func addClass(section: Section) {
        Singleton.mySchedules[Singleton.semesterIndex][scheduleIndex].append(section)
        AppDelegate.saveMySchedules()
        table.reloadData()
    }
    
    func export() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case EKAuthorizationStatus.notDetermined:
            EKEventStore().requestAccess(to: .event, completion: {
                (accessGranted: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if accessGranted {
                        self.accessGranted()
                    } else {
                        self.accessDenied()
                    }
                }
            })
        
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            accessDenied()
            
        case EKAuthorizationStatus.authorized:
            accessGranted()
        }
    }
    
    func accessDenied() {
        let settingsNav = UINavigationController()
        settingsNav.navigationBar.tintColor = Singleton.mainAppColor
        let settingsView = UIViewController()
        settingsNav.pushViewController(settingsView, animated: false)
        let label = UILabel()
        settingsView.view.addSubview(label)
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "To add schedules to your calendar you must enable access in settings"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(
            x: 10,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + 10,
            width: view.frame.width - 20,
            height: 300
        )
        let button = UIButton()
        settingsView.view.addSubview(button)
        button.backgroundColor = Singleton.mainAppColor
        button.setTitle("Go to settings", for: .normal)
        button.titleLabel!.font = .preferredFont(forTextStyle: .title2)
        button.frame = CGRect(
            x: 40,
            y: label.frame.maxY + 10,
            width: view.frame.width - 80,
            height: 50
        )
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        settingsView.view.backgroundColor = .white
        settingsView.navigationItem.title = "Export"
        settingsView.navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        settingsNav.modalPresentationStyle = .overFullScreen
        navigationController?.present(settingsNav, animated: true, completion: nil)
    }
    
    func accessGranted() {
        let calendarSelection = CalendarSelection()
        calendarSelection.scheduleIndex = scheduleIndex
        let addToCalendarNav = UINavigationController()
        addToCalendarNav.pushViewController(calendarSelection, animated: false)
        addToCalendarNav.modalPresentationStyle = .overFullScreen
        addToCalendarNav.navigationBar.tintColor = Singleton.mainAppColor
        navigationController?.present(addToCalendarNav, animated: true, completion: nil)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func goToSettings() {
        let settings = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(settings!, options: [:], completionHandler: nil)
        dismiss(animated: true, completion: nil)
    }
    
    class TableCell: UITableViewCell {
        var section: Section!
        var cellSize: CGSize!
        var crnWidth: CGFloat!
        var courseCodeWidth: CGFloat!
        var textHeight: CGFloat!
        var margin: CGFloat!
        
        let crn = UILabel()
        let title = UILabel()
        let code = UILabel()
        let teacher = UILabel()
        let credits = UILabel()
        let capacity = UILabel()
        let online = UILabel()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(crn)
            crn.font = .preferredFont(forTextStyle: .title3)
            crn.adjustsFontSizeToFitWidth = true
            crn.textAlignment = .center
            
            contentView.addSubview(title)
            title.font = .preferredFont(forTextStyle: .title3)
            title.adjustsFontSizeToFitWidth = true
            
            contentView.addSubview(code)
            code.font = .preferredFont(forTextStyle: .body)
            code.textColor = Singleton.lightGrayTextColor
            code.adjustsFontSizeToFitWidth = true
            
            contentView.addSubview(teacher)
            teacher.font = .preferredFont(forTextStyle: .body)
            teacher.textColor = Singleton.lightGrayTextColor
            teacher.adjustsFontSizeToFitWidth = true
            
            contentView.addSubview(credits)
            credits.font = .preferredFont(forTextStyle: .body)
            credits.textColor = Singleton.lightGrayTextColor
            credits.adjustsFontSizeToFitWidth = true
            
            contentView.addSubview(capacity)
            capacity.font = .preferredFont(forTextStyle: .body)
            capacity.textColor = Singleton.lightGrayTextColor
            capacity.adjustsFontSizeToFitWidth = true
            
            contentView.addSubview(online)
            online.font = .preferredFont(forTextStyle: .body)
            online.textColor = Singleton.mainAppColor
            online.adjustsFontSizeToFitWidth = true
            online.textAlignment = .center
            
            textHeight = title.font.capHeight + code.font.capHeight + credits.font.capHeight
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            margin = (cellSize.height - textHeight) / 4
            
            crn.text = "\(section.crn)"
            crn.sizeToFit()
            crn.frame = CGRect(
                x: 10,
                y: (cellSize.height - crn.frame.height)/2,
                width: crnWidth,
                height: crn.frame.height
            )
            
            title.text = section.courseTitle
            title.sizeToFit()
            title.frame = CGRect(
                x: crn.frame.maxX + 10,
                y: margin - (title.font.ascender - title.font.capHeight),
                width: cellSize.width - crn.frame.maxX - 20,
                height: title.frame.height
            )
            
            code.text = "\(section.subjectID)-\(section.courseID)"
            code.sizeToFit()
            code.frame = CGRect(
                x: crn.frame.maxX + 10,
                y: (title.frame.maxY + title.font.descender) + margin - (code.font.ascender - code.font.capHeight),
                width: courseCodeWidth,
                height: code.frame.height
            )
            
            credits.text = "\(section.credits) credits"
            credits.sizeToFit()
            credits.frame = CGRect(
                x: crn.frame.maxX + 10,
                y: (code.frame.maxY + code.font.descender) + margin - (credits.font.ascender - credits.font.capHeight),
                width: courseCodeWidth,
                height: credits.frame.height
            )
            
            if let teacherName = section.instructors.first {
                teacher.text = "\(teacherName.first) \(teacherName.last)"
            } else {
                teacher.text = "Instructor TBA"
            }
            
            teacher.sizeToFit()
            teacher.frame = CGRect(
                x: code.frame.maxX + 20,
                y: (title.frame.maxY + title.font.descender) + margin - (teacher.font.ascender - teacher.font.capHeight),
                width: cellSize.width - code.frame.maxX - 30,
                height: teacher.frame.height
            )
            
            capacity.text = "enrollment: \(section.enrollment)/\(section.enrollmentMax)"
            capacity.sizeToFit()
            capacity.frame = CGRect(
                x: credits.frame.maxX + 20,
                y: (teacher.frame.maxY + teacher.font.descender) + margin - (capacity.font.ascender - capacity.font.capHeight),
                width: cellSize.width - code.frame.maxX - 30,
                height: capacity.frame.height
            )
            
            if section.isOnline {
                online.text = "online"
            } else {
                online.text = ""
            }
            online.sizeToFit()
            online.frame = CGRect(
                x: 10,
                y: crn.frame.maxY + 5,
                width: crnWidth,
                height: online.frame.height
            )
        }
    }
    
    class AddClassTableCell: UITableViewCell {
        let container = UIView()
        let plusIcon = UIImageView()
        let label = UILabel()
        var cellSize: CGSize!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(container)
            container.addSubview(plusIcon)
            container.addSubview(label)
            
            plusIcon.image = #imageLiteral(resourceName: "plusIcon")
            
            label.textColor = Singleton.lightGrayTextColor
            label.font = .preferredFont(forTextStyle: .title2)
            label.text = "Add another class"
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            plusIcon.frame = CGRect(
                x: 0,
                y: (cellSize.height - 20)/2,
                width: 20,
                height: 20
            )

            label.sizeToFit()
            label.frame = CGRect(
                x: plusIcon.frame.maxX + 20,
                y: 0,
                width: label.frame.width,
                height: cellSize.height
            )
            
            container.frame = CGRect(
                x: (cellSize.width - plusIcon.frame.width - label.frame.width - 20)/2,
                y: 0,
                width: plusIcon.frame.width + label.frame.width + 20,
                height: cellSize.height
            )
        }
    }
}
