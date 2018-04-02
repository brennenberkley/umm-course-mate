import Foundation
import UIKit

class Register: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: CreateScheduleProtocol!
    var table = UITableView()
    var selectedSections = [Section]()
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
        for section in selectedSections {
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
        
        navigationItem.title = "Create Schedule"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(save)
        )
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
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
        table.rowHeight = table.frame.width * 0.3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    func save() {
        let saveMenu = UIAlertController.init(title: "Save Schedule", message: "Enter a name for this schedule", preferredStyle: .alert)
        saveMenu.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = Singleton.schedule[Singleton.semesterIndex].semesterID
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
        })
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            saveMenu.dismiss(animated: true, completion: nil)
        })
        
        let saveButton = UIAlertAction.init(title: "Save", style: .default, handler: { (UIAlertAction) -> Void in
            saveMenu.dismiss(animated: true, completion: nil)
            Singleton.mySchedules[Singleton.semesterIndex].append(self.selectedSections)
            let name = saveMenu.textFields!.first!.text
            if name != "" {
                Singleton.mySchedulesNames[Singleton.semesterIndex].append(name!)
            } else {
                Singleton.mySchedulesNames[Singleton.semesterIndex].append(Singleton.schedule[Singleton.semesterIndex].semesterID)
            }
            AppDelegate.saveMySchedules()
            self.dismiss(animated: true, completion: nil)
            self.delegate.closedModal(done: true)
        })
        
        saveMenu.addAction(cancel)
        saveMenu.addAction(saveButton)
        saveMenu.preferredAction = saveButton
        
        navigationController!.present(saveMenu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        cell.section = selectedSections[indexPath.row]
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.crnWidth = crnWidth
        cell.courseCodeWidth = courseCodeWidth
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = SectionDetails()
        destination.section = selectedSections[indexPath.row]
        destination.showSearch = false
        navigationController?.pushViewController(destination, animated: true)
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
}
