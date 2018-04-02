import Foundation
import UIKit

class RegisterSections: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: CreateScheduleProtocol!
    var table = UITableView()
    var label = UILabel()
    var possibleSections: [Section]!
    var selectedCourse: Int!
    var registering = false
    var options: [[Section]]!
    var optionsUpdated: [[Section]]!
    var selectedSections = [Section]()
    var selectedSectionsUpdated = [Section]()
    
    var codeWidth:CGFloat {
        var width:CGFloat = 0
        for section in possibleSections {
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
    
    var enrollmentWidth:CGFloat {
        var width:CGFloat = 0
        for section in possibleSections {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Create Schedule"
        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        updateOptions()
        
        container.addSubview(label)
        container.addSubview(table)
        
        label.backgroundColor = .white
        label.text = "Choose a section for \(possibleSections.first!.courseTitle)"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(
            x: 10,
            y: 0,
            width: container.frame.width - 20,
            height: 120
        )
        label.addBorder(color: .normal, sides: [.top])
        
        table.frame = CGRect(
            x: 0,
            y: label.frame.maxY,
            width: container.frame.width,
            height: container.frame.height - label.frame.maxY
        )
        table.addBorder(color: .normal, sides: [.top])
        table.dataSource = self
        table.delegate = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = table.indexPathForSelectedRow {
            table.deselectRow(at: index, animated: true)
        }
        updateOptions()
    }
    
    func updateOptions() {
        optionsUpdated = options
        if registering {
            selectedSectionsUpdated = selectedSections
            while optionsUpdated.first!.count == 1 {
                selectedSectionsUpdated.append(optionsUpdated.first!.first!)
                optionsUpdated.removeFirst()
            }
            possibleSections = optionsUpdated.first!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.code.text = "\(possibleSections[indexPath.row].sectionID)"
        if let teacher = possibleSections[indexPath.row].instructors.first {
            cell.teacher.text = "\(teacher.first) \(teacher.last)"
            cell.teacher.textColor = .black
        } else {
            cell.teacher.text = "Instructor TBA"
            cell.teacher.textColor = Singleton.lightGrayTextColor
        }
        if possibleSections[indexPath.row].status == "A" {
            let enrolled = possibleSections[indexPath.row].enrollment
            let max = possibleSections[indexPath.row].enrollmentMax
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
        cell.codeWidth = codeWidth
        cell.enrollmentWidth = enrollmentWidth
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = indexPath.row
        selectedSectionsUpdated.append(possibleSections[indexPath.row])
        if registering {
            optionsUpdated.removeFirst()
            while optionsUpdated.count > 0 {
                if optionsUpdated.first!.count == 1 {
                    selectedSectionsUpdated.append(optionsUpdated.first!.first!)
                    optionsUpdated.removeFirst()
                } else {
                    let destination = RegisterSections()
                    destination.registering = true
                    destination.options = optionsUpdated
                    destination.selectedSections = selectedSectionsUpdated
                    destination.delegate = delegate
                    destination.updateOptions()
                    navigationController?.pushViewController(destination, animated: true)
                    return
                }
            }
            let destination = Register()
            destination.delegate = delegate
            destination.selectedSections = selectedSectionsUpdated
            navigationController?.pushViewController(destination, animated: true)
            
        } else {
            let destination = SectionDetails()
            destination.section = possibleSections[indexPath.row]
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    class TableCell: UITableViewCell {
        
        var code = UILabel()
        var teacher = UILabel()
        var enrollment = UILabel()
        var full = UILabel()
        
        var cellSize: CGSize!
        var codeWidth: CGFloat!
        var enrollmentWidth: CGFloat!
        var isFull = false
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            code.font = .preferredFont(forTextStyle: .body)
            contentView.addSubview(code)
            
            enrollment.font = .preferredFont(forTextStyle: .body)
            enrollment.textAlignment = .center
            enrollment.adjustsFontSizeToFitWidth = true
            contentView.addSubview(enrollment)
            
            teacher.font = .preferredFont(forTextStyle: .body)
            teacher.adjustsFontSizeToFitWidth = true
            teacher.minimumScaleFactor = 0.7
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
            
            teacher.frame = CGRect(
                x: code.frame.maxX + 10,
                y: 0,
                width: cellSize.width - (40 + codeWidth + enrollmentWidth),
                height: cellSize.height
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
