import Foundation
import UIKit

protocol SubjectSelectionProtocol {
    func refresh()
}

class SubjectSelection: UIViewController, UITableViewDelegate, UITableViewDataSource, SubjectSelectionProtocol {
    
    //MARK: - Property Declarations
    
    var subjects: [Subject]!
    var sortedSubjects = [[Subject]]()
    var alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var table = UITableView()
    var codeWidth:CGFloat = 0
    var letterWidth:CGFloat = 0
    var loadingView = UIView()
    let loadingText = UILabel()
    let loadingSubtext = UILabel()
    let loadingIcon = UIImageView()
    let retryButton = UIButton()
    var delegate: AppDelegateProtocol!
    var settingsView: Settings?
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(search)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            image: #imageLiteral(resourceName: "gearIcon"),
            style: .plain,
            target: self,
            action: #selector(settings)
        )
        let backItem = UIBarButtonItem(title: "Subjects", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        view.addSubview(table)
        
        if Singleton.loadStatus.isSubset(of: .loaded)
        {
            subjects = Singleton.schedule[Singleton.semesterIndex].subjects
            sortSubjects()
            navigationItem.title = Singleton.schedule[Singleton.semesterIndex].semesterID
            calculateWidths()
        } else {
            navigationItem.title = "Catalog"
            navigationItem.leftBarButtonItem!.isEnabled = false
            navigationItem.rightBarButtonItem!.isEnabled = false
            loadingView.frame = CGRect(
                x: 40,
                y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height + 40,
                width: view.frame.width - 80,
                height: view.frame.width - 80
            )
            loadingView.layer.cornerRadius = 20
            loadingView.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
            view.addSubview(loadingView)
            
            loadingText.font = .preferredFont(forTextStyle: .title1)
            loadingText.adjustsFontSizeToFitWidth = true
            loadingText.textAlignment = .center
            loadingText.frame = CGRect(
                x: 15,
                y: (loadingView.frame.height - 110) / 2,
                width: loadingView.frame.height - 30,
                height: 50
            )
            loadingView.addSubview(loadingText)
            loadingIcon.frame = CGRect(
                x: (loadingView.frame.width - 50) / 2,
                y: loadingText.frame.maxY + 10,
                width: 50,
                height: 50
            )
            loadingView.addSubview(loadingIcon)
            loadingIcon.image = #imageLiteral(resourceName: "errorIcon")
            var imagesArray = [UIImage]()
            for i in 1...8 {
                let imageName = "LoadingIcon\(i)"
                let image = UIImage(named:imageName)
                imagesArray.append(image!)
            }
            loadingIcon.animationImages = imagesArray
            loadingIcon.animationDuration = 0.6
            
            loadingSubtext.font = .preferredFont(forTextStyle: .body)
            loadingSubtext.textColor = Singleton.darkGrayTextColor
            loadingSubtext.textAlignment = .center
            let bottomSpace = (loadingView.frame.height - loadingIcon.frame.maxY)/2
            loadingSubtext.frame = CGRect(
                x: 15,
                y: loadingIcon.frame.maxY + bottomSpace - 15,
                width: loadingView.frame.width - 30,
                height: 30
            )
            loadingView.addSubview(loadingSubtext)
            
            retryButton.frame = CGRect(
                x: 0,
                y: 0,
                width: loadingView.frame.width,
                height: loadingView.frame.height
            )
            retryButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
            loadingView.addSubview(retryButton)
            
            if Singleton.loadStatus == .downloading || Singleton.loadStatus == .notLoaded {
                loadingText.text = "Downloading Data"
                loadingIcon.startAnimating()
                retryButton.isEnabled = false
            } else if Singleton.loadStatus == .processingDownload {
                loadingText.text = "Processing Data"
                loadingIcon.startAnimating()
                retryButton.isEnabled = false
            } else if Singleton.loadStatus == .downloadFailed {
                loadingText.text = "Download Failed"
                loadingSubtext.text = "Tap to retry"
                loadingIcon.stopAnimating()
                retryButton.isEnabled = true
            }
            table.isScrollEnabled = false
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
    
    func retry() {
        loadingText.text = "Downloading Data"
        loadingSubtext.text = ""
        loadingIcon.startAnimating()
        delegate.retry()
    }
    
    func refresh() {
        subjects = Singleton.schedule[Singleton.semesterIndex].subjects
        sortSubjects()
        calculateWidths()
        table.reloadData()
        navigationItem.title = Singleton.schedule[Singleton.semesterIndex].semesterID
        settingsView = nil
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
    
    func search() {
        let searchView = Search()
        searchView.presenting = self
        searchView.delegate = delegate
        searchView.modalPresentationStyle = .popover
        navigationController?.present(searchView, animated: false, completion: nil)
    }
    
    func updateStatus() {
        guard isViewLoaded else {
            return
        }
        if Singleton.loadStatus.isSubset(of: .loaded) {
            loadingView.removeFromSuperview()
            subjects = Singleton.schedule[Singleton.semesterIndex].subjects
            sortSubjects()
            calculateWidths()
            navigationItem.title = Singleton.schedule[Singleton.semesterIndex].semesterID
            navigationItem.leftBarButtonItem!.isEnabled = true
            navigationItem.rightBarButtonItem!.isEnabled = true
            table.reloadData()
            table.isScrollEnabled = true
            loadingView.removeFromSuperview()
        } else if Singleton.loadStatus == .downloading || Singleton.loadStatus == .notLoaded {
            loadingText.text = "Downloading Data"
            loadingSubtext.text = ""
            loadingIcon.startAnimating()
            retryButton.isEnabled = false
        } else if Singleton.loadStatus == .processingDownload {
            loadingText.text = "Processing Data"
            loadingSubtext.text = ""
            loadingIcon.startAnimating()
            retryButton.isEnabled = false
        } else if Singleton.loadStatus == .downloadFailed {
            loadingText.text = "Download Failed"
            loadingSubtext.text = "Tap to retry"
            loadingIcon.stopAnimating()
            retryButton.isEnabled = true
        }
        if let settingsView = settingsView {
            settingsView.updateStatus()
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
        let destination = CourseSelection()
        destination.delegate = delegate
        destination.subjectIndex = selectedSubject
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func settings() {
        let settingsNav = UINavigationController()
        settingsNav.navigationBar.tintColor = Singleton.mainAppColor
        let settingsView = Settings()
        self.settingsView = settingsView
        settingsView.delegate = self
        settingsNav.pushViewController(settingsView, animated: false)
        
        settingsNav.modalPresentationStyle = .overFullScreen
        navigationController?.present(settingsNav, animated: true, completion: nil)
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
