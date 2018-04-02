import Foundation
import UIKit

class AddClassSections: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Property Declarations
    
    var delegate: AddClassProtocol!
    var table = UITableView()
    var sections: [Section]!
    var subjectIndex:Int!
    var courseIndex:Int!
    
    var codeWidth:CGFloat {
        var width:CGFloat = 0
        for section in sections {
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
        for section in sections {
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
        for section in sections {
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
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add a Class"
        
        sections = Singleton.schedule[Singleton.semesterIndex].subjects[subjectIndex].courses[courseIndex].sections
        
        table.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(table)
        
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 44
        table.separatorInset.left = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.codeWidth = codeWidth
        cell.onlineWidth = onlineWidth
        cell.isOnline = sections[indexPath.row].isOnline
        cell.enrollmentWidth = enrollmentWidth
        cell.code.text = "\(sections[indexPath.row].sectionID)"
        if let teacher = sections[indexPath.row].instructors.first {
            cell.teacher.text = "\(teacher.first) \(teacher.last)"
            cell.teacher.textColor = .black
        } else {
            cell.teacher.text = "Instructor TBA"
            cell.teacher.textColor = Singleton.lightGrayTextColor
        }
        
        if sections[indexPath.row].status == "A" {
            let enrolled = sections[indexPath.row].enrollment
            let max = sections[indexPath.row].enrollmentMax
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
        dismiss(animated: true, completion: nil)
        delegate.addClass(section: sections[indexPath.row])
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
