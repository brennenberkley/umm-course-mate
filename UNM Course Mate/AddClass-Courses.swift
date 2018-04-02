import Foundation
import UIKit

class AddClassCourses: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Property Declarations
    
    var delegate: AddClassProtocol!
    var subjectIndex:Int!
    var courses: [Course]!
    var selectedCourse:Int!
    var codeWidth:CGFloat {
        var width:CGFloat = 0
        for course in courses {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .body)
            tempLabel.text = course.courseID
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        return width
    }
    var table = UITableView()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add a Class"        
        courses = Singleton.schedule[Singleton.semesterIndex].subjects[subjectIndex].courses
        
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
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    // MARK: - Table Management
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.codeWidth = codeWidth
        cell.code.text = courses[indexPath.row].courseID
        cell.label.text = courses[indexPath.row].title
        var isCancelled = true
        for section in courses[indexPath.row].sections {
            if section.status == "A" {
                isCancelled = false
                break
            }
        }
        cell.isCancelled = isCancelled
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = indexPath.row
        let destination = AddClassSections()
        destination.subjectIndex = subjectIndex
        destination.courseIndex = selectedCourse
        destination.delegate = delegate
        navigationController?.pushViewController(destination, animated: true)
    }
    
    class TableCell: UITableViewCell {
        
        var code = UILabel()
        var label = UILabel()
        var cellSize: CGSize!
        var codeWidth: CGFloat!
        var isCancelled = false
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            code.font = .preferredFont(forTextStyle: .body)
            contentView.addSubview(code)
            
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            contentView.addSubview(label)
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
            label.frame = CGRect(
                x: code.frame.maxX + 10,
                y: 0,
                width: cellSize.width - (code.frame.maxX + 10),
                height: cellSize.height
            )
            
            if isCancelled {
                code.textColor = Singleton.lightGrayTextColor
                label.textColor = Singleton.lightGrayTextColor
            } else {
                code.textColor = .black
                label.textColor = .black
            }
        }
    }
}
