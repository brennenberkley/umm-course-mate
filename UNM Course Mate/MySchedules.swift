import Foundation
import UIKit

class MySchedules: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table = UITableView()
    
    var classesWidth:CGFloat {
        var width:CGFloat = 0
        for schedule in Singleton.mySchedules[Singleton.semesterIndex] {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .title3)
            if schedule.count == 1 {
                tempLabel.text = "\(schedule.count) class"
            } else {
                tempLabel.text = "\(schedule.count) classes"
            }
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        return width
    }
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "My Schedules"
        let backItem = UIBarButtonItem(title: "Schedules", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(edit)
        )
        
        table.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(table)
        
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.register(AddClassTableCell.self, forCellReuseIdentifier: "add")
        table.rowHeight = 47
        table.separatorInset.left = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
        table.reloadData()
    }
    
    // MARK: - Table Management
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.mySchedules[Singleton.semesterIndex].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex].count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
            cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
            cell.name.text = Singleton.mySchedulesNames[Singleton.semesterIndex][indexPath.row]
            if Singleton.mySchedules[Singleton.semesterIndex][indexPath.row].count == 1 {
                cell.classes.text = "\(Singleton.mySchedules[Singleton.semesterIndex][indexPath.row].count) class"
            } else {
                cell.classes.text = "\(Singleton.mySchedules[Singleton.semesterIndex][indexPath.row].count) classes"
            }
            cell.classesWidth = classesWidth
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add") as! AddClassTableCell
            cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
            cell.layout()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex].count {
            let destination = ScheduleDetails()
            destination.scheduleIndex = indexPath.row
            navigationController!.pushViewController(destination, animated: true)
        } else {
            table.deselectRow(at: indexPath, animated: true)
            newSchedule()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < Singleton.mySchedules[Singleton.semesterIndex].count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if table.isEditing {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            Singleton.mySchedules[Singleton.semesterIndex].remove(at: indexPath.row)
            Singleton.mySchedulesNames[Singleton.semesterIndex].remove(at: indexPath.row)
            table.beginUpdates()
            table.deleteRows(at: [indexPath], with: .automatic)
            table.endUpdates()
            AppDelegate.saveMySchedules()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = Singleton.mySchedules[Singleton.semesterIndex][sourceIndexPath.row]
        Singleton.mySchedules[Singleton.semesterIndex].remove(at: sourceIndexPath.row)
        Singleton.mySchedules[Singleton.semesterIndex].insert(movedObject, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.dataSource!.tableView!(tableView, commit: .delete, forRowAt: indexPath)
        }
        deleteButton.backgroundColor = Singleton.mainAppColor
        return [deleteButton]
    }
    
    func edit() {
        table.setEditing(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done)
        )
        table.isEditing = true
    }
    
    func done() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(edit)
        )
        table.isEditing = false
        AppDelegate.saveMySchedules()
    }
    
    func newSchedule() {
        let newScheduleMenu = UIAlertController.init(title: "New Schedule", message: "Enter a name for this schedule", preferredStyle: .alert)
        newScheduleMenu.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = "New Schedule"
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
        })
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            newScheduleMenu.dismiss(animated: true, completion: nil)
        })
        
        let saveButton = UIAlertAction.init(title: "Save", style: .default, handler: { (UIAlertAction) -> Void in
            newScheduleMenu.dismiss(animated: true, completion: nil)
            Singleton.mySchedules[Singleton.semesterIndex].append([Section]())
            let name = newScheduleMenu.textFields!.first!.text
            if name != "" {
                Singleton.mySchedulesNames[Singleton.semesterIndex].append(name!)
            } else {
                Singleton.mySchedulesNames[Singleton.semesterIndex].append("New Schedule")
            }
            AppDelegate.saveMySchedules()
            self.dismiss(animated: true, completion: nil)
            self.table.beginUpdates()
            self.table.insertRows(
                at: [[0, Singleton.mySchedulesNames[Singleton.semesterIndex].count - 1]],
                with: .automatic
            )
            self.table.endUpdates()
            let destination = ScheduleDetails()
            destination.scheduleIndex = Singleton.mySchedules[Singleton.semesterIndex].count - 1
            self.navigationController!.pushViewController(destination, animated: true)
        })
        
        newScheduleMenu.addAction(cancel)
        newScheduleMenu.addAction(saveButton)
        newScheduleMenu.preferredAction = saveButton
        
        navigationController!.present(newScheduleMenu, animated: true, completion: nil)
    }
    
    class TableCell: UITableViewCell {
        
        var name = UILabel()
        var classes = UILabel()
        var cellSize: CGSize!
        var classesWidth: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            name.font = .preferredFont(forTextStyle: .title3)
            name.adjustsFontSizeToFitWidth = true
            name.minimumScaleFactor = 0.8
            contentView.addSubview(name)
            
            classes.font = .preferredFont(forTextStyle: .title3)
            classes.adjustsFontSizeToFitWidth = true
            contentView.addSubview(classes)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if isEditing {
                name.frame = CGRect(
                    x: 15,
                    y: 0,
                    width: cellSize.width - classesWidth - 82,
                    height: cellSize.height
                )
            } else {
                name.frame = CGRect(
                    x: 15,
                    y: 0,
                    width: cellSize.width - classesWidth - 45,
                    height: cellSize.height
                )
            }
            classes.frame = CGRect(
                x: name.frame.maxX + 15,
                y: 0,
                width: classesWidth,
                height: cellSize.height
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
            label.font = .preferredFont(forTextStyle: .title3)
            label.text = "Add another schedule"
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            plusIcon.frame = CGRect(
                x: 0,
                y: (cellSize.height - 18)/2,
                width: 18,
                height: 18
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
