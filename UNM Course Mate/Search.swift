import Foundation
import UIKit

class Search: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var delegate: AppDelegateProtocol!
    var presenting: UIViewController!
    var container = UIView()
    var searchController = UISearchController(searchResultsController: nil)
    var bar: UISearchBar!
    var table = UITableView()
    var recent = UIView()
    var categoryWidth:CGFloat!
    
    var subjects = [Subject]()
    var courses = [Course]()
    
    var subjectResults = [Subject]()
    var courseResults = [Course]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(container)
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height,
            width: view.frame.width,
            height: view.frame.height - UIApplication.shared.statusBarFrame.height
        )
        container.backgroundColor = .white
      
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        let tempLabel = UILabel()
        tempLabel.font = .preferredFont(forTextStyle: .callout)
        tempLabel.text = "instructor"
        tempLabel.sizeToFit()
        categoryWidth = tempLabel.frame.width
        
        bar = searchController.searchBar
        container.addSubview(bar)
        bar.delegate = self
        bar.sizeToFit()
        bar.barTintColor = Singleton.grayBarColor
        bar.tintColor = Singleton.mainAppColor
        bar.isTranslucent = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 44
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset.left = 10
        
        recent.backgroundColor = .white
        
        container.addSubview(recent)
        
        // create searchable arrays
        subjects = Singleton.schedule[Singleton.semesterIndex].subjects
        
        for subject in subjects {
            for course in subject.courses {
                courses.append(course)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        perform(#selector(showSearchBar), with: nil, afterDelay: 0)
    }
    
    func showSearchBar() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        recent.frame = CGRect(
            x: 0,
            y: bar.frame.height,
            width: container.frame.width,
            height: container.frame.height - bar.frame.height - keyboardSize!.height
        )
        table.frame = recent.frame
    }
    
    func keyboardWillHide(notification: NSNotification) {
        recent.frame = CGRect(
            x: 0,
            y: bar.frame.height,
            width: container.frame.width,
            height: container.frame.height - bar.frame.height
        )
        table.frame = recent.frame
    }
    
    //MARK: Table Management
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return subjectResults.count
        case 1:
            return courseResults.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        if categoryWidth < table.frame.width * 0.3 {
            cell.categoryWidth = categoryWidth
        } else {
            cell.categoryWidth = table.frame.width * 0.3
        }
        
        switch indexPath.section {
        case 0:
            cell.category.text = "subject"
            cell.object.text = subjectResults[indexPath.row].name
        case 1:
            cell.category.text = "course"
            cell.object.text = courseResults[indexPath.row].title
        default: break
        }
        
        cell.layout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: false, completion: nil)
        dismiss(animated: true, completion: {
            switch indexPath.section {
            case 0: //subject
                self.delegate.goToSearchResults(subject: self.subjectResults[indexPath.row])
            case 1: //course
                self.delegate.goToSearchResults(course: self.courseResults[indexPath.row])
            default: break
            }
        })
    }
    
    //MARK: Search Management
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            table.removeFromSuperview()
            container.addSubview(recent)
        } else {
            recent.removeFromSuperview()
            container.addSubview(table)
            
            func courseFilter(course: Course) -> Bool {
                return course.title.range(of: searchText, options: .caseInsensitive) != nil
            }
            
            func subjectFilter(subject: Subject) -> Bool {
                if let _ = subject.subjectID.range(of: searchText, options: .caseInsensitive) {
                    return true
                }
                if let _ = subject.name.range(of: searchText, options: .caseInsensitive) {
                    return true
                }
                return false
            }
            
            courseResults = courses.filter(courseFilter)
            subjectResults = subjects.filter(subjectFilter)
            
            table.reloadData()
        }
    }
    class TableCell: UITableViewCell {
        
        var cellSize: CGSize!
        var object = UILabel()
        var category = UILabel()
        var categoryWidth: CGFloat!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            object.font = .preferredFont(forTextStyle: .body)
            category.adjustsFontSizeToFitWidth = true
            category.minimumScaleFactor = 0.7
            contentView.addSubview(object)
            
            category.font = .preferredFont(forTextStyle: .callout)
            category.adjustsFontSizeToFitWidth = true
            category.minimumScaleFactor = 0.7
            category.textColor = Singleton.lightGrayTextColor
            contentView.addSubview(category)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            category.frame = CGRect(
                x: cellSize.width - (categoryWidth + 10),
                y: 0,
                width: categoryWidth,
                height: cellSize.height
            )
            object.frame = CGRect(
                x: 10,
                y: 0,
                width: cellSize.width - (10 + category.frame.width + 10),
                height: cellSize.height
            )
        }
    }
}
