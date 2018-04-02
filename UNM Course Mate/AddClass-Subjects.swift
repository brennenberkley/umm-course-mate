import Foundation
import UIKit

class AddClassSubjects: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Property Declarations
    
    var delegate: AddClassProtocol!
    var subjects: [Subject]!
    var sortedSubjects = [[Subject]]()
    var alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var table = UITableView()
    var codeWidth:CGFloat = 0
    var letterWidth:CGFloat = 0
    var loadingView = UIView()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add a Class"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        let backItem = UIBarButtonItem(title: "Subjects", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        view.addSubview(table)
        
        if Singleton.loadStatus.isSubset(of: .loaded) {
            subjects = Singleton.schedule[Singleton.semesterIndex].subjects
            sortSubjects()
            calculateWidths()
        }
        
        table.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        table.delegate = self
        table.dataSource = self
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 44
        table.sectionHeaderHeight = 0
        table.tintColor = Singleton.mainAppColor
        table.separatorInset.left = letterWidth + 20
        table.reloadData()
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    func sortSubjects() {
        sortedSubjects = [[Subject]]()
        for i in 0...(alphabet.count - 1) {
            sortedSubjects.append([Subject]())
            for j in 0...(subjects.count - 1) {
                if subjects[j].subjectID.characters.first == alphabet[i].characters.first {
                    sortedSubjects[sortedSubjects.count - 1].append(subjects[j])
                }
            }
        }
    }
    
    func calculateWidths() {
        var width:CGFloat = 0
        for subject in subjects {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .body)
            tempLabel.text = subject.subjectID
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
        }
        codeWidth = width
        width = 0
        for subject in subjects {
            let tempLabel = UILabel()
            tempLabel.font = .preferredFont(forTextStyle: .headline)
            tempLabel.text = "\(subject.subjectID.characters.first!)"
            tempLabel.sizeToFit()
            if tempLabel.frame.width > width {
                width = tempLabel.frame.width
            }
            letterWidth = width
        }
    }
    
    // MARK: - Table Management
    func numberOfSections(in tableView: UITableView) -> Int {
        return alphabet.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Singleton.loadStatus.isSubset(of: .loaded) {
            return sortedSubjects[section].count
        } else {
            return 0
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return alphabet
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.letterWidth = letterWidth
        cell.codeWidth = codeWidth
        cell.code.text = sortedSubjects[indexPath.section][indexPath.row].subjectID
        cell.label.text = sortedSubjects[indexPath.section][indexPath.row].name
        cell.layout()
        if indexPath.row == 0 {
            cell.letter.text = "\(cell.code.text!.characters.first!)"
        } else {
            cell.letter.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedSubject = 0
        if indexPath.section > 0 {
            for i in 0...(indexPath.section - 1) {
                selectedSubject = selectedSubject + sortedSubjects[i].count
            }
        }
        selectedSubject = selectedSubject + indexPath.row
        let destination = AddClassCourses()
        destination.delegate = delegate
        destination.subjectIndex = selectedSubject
        navigationController?.pushViewController(destination, animated: true)
    }
    
    class TableCell: UITableViewCell {
        
        var letter = UILabel()
        var code = UILabel()
        var label = UILabel()
        var cellSize: CGSize!
        var letterWidth:CGFloat!
        var codeWidth: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            letter.font = .preferredFont(forTextStyle: .headline)
            contentView.addSubview(letter)
            
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
            letter.frame = CGRect(
                x: 10,
                y: 0,
                width: letterWidth,
                height: cellSize.height
            )
            code.frame = CGRect(
                x: letter.frame.maxX + 10,
                y: 0,
                width: codeWidth,
                height: cellSize.height
            )
            label.frame = CGRect(
                x: code.frame.maxX + 8,
                y: 0,
                width: cellSize.width - (code.frame.maxX + 8 + 15),
                height: cellSize.height
            )
        }
    }
}
