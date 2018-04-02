import Foundation
import UIKit

class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SubjectSelectionProtocol!
    let updateLabel = UILabel()
    let updateIcon = UIImageView()
    let table = UITableView()
    let websiteLabel = UITextView()
    let container = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(done)
        )
        
        let semesterLabel = UILabel()
        container.addSubview(semesterLabel)
        semesterLabel.font = .preferredFont(forTextStyle: .title1)
        semesterLabel.text = "Choose a semester"
        semesterLabel.textAlignment = .center
        semesterLabel.numberOfLines = 0
        semesterLabel.sizeToFit()
        semesterLabel.frame = CGRect(
            x: 0,
            y: 20,
            width: view.frame.width,
            height: semesterLabel.frame.height + 40
        )
        
        table.delegate = self
        table.dataSource = self
        table.separatorInset.left = 15
        table.rowHeight = 44
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
        table.frame = CGRect(
            x: 0,
            y: semesterLabel.frame.maxY,
            width: view.frame.width,
            height: table.rowHeight * CGFloat(Singleton.schedule.count)
        )
        table.addBorder(color: .normal, sides: [.top, .bottom])
        container.addSubview(table)
        
        container.addSubview(websiteLabel)
        websiteLabel.text = "Please help keep this app on the app store by donating or getting involved"
        websiteLabel.font = UIFont.preferredFont(forTextStyle: .body)
        websiteLabel.textAlignment = .center
        websiteLabel.frame = CGRect(
            x: 15,
            y: table.frame.maxY + 70,
            width: container.frame.width - 30,
            height: 100
        )
        websiteLabel.sizeToFit()
        websiteLabel.frame = CGRect(
            x: 15,
            y: table.frame.maxY + 50,
            width: container.frame.width - 30,
            height: websiteLabel.frame.height
        )
        
        let websiteButton = UIButton()
        container.addSubview(websiteButton)
        websiteButton.backgroundColor = Singleton.mainAppColor
        websiteButton.layer.cornerRadius = 5
        websiteButton.frame = CGRect(
            x: 40,
            y: websiteLabel.frame.maxY + 10,
            width: container.frame.width - 80,
            height: 40
        )
        websiteButton.setTitleColor(.white, for: .normal)
        websiteButton.setTitle("Go to Website", for: .normal)
        websiteButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        websiteButton.addTarget(self, action: #selector(goToWebsite), for: .touchUpInside)
        
        container.addSubview(updateLabel)
        updateLabel.textAlignment = .center
        updateLabel.adjustsFontSizeToFitWidth = true
        updateLabel.numberOfLines = 0
        updateLabel.frame = CGRect(
            x: 65,
            y: container.frame.height - 35,
            width: container.frame.width - 130,
            height: 20
        )

        updateIcon.frame = CGRect(
            x: container.frame.width - 35,
            y: container.frame.height - 35,
            width: 20,
            height: 20
        )
        container.addSubview(updateIcon)
        var imagesArray = [UIImage]()
        for i in 1...8 {
            let imageName = "LoadingIcon\(i)"
            let image = UIImage(named:imageName)
            imagesArray.append(image!)
        }
        updateIcon.animationImages = imagesArray
        updateIcon.animationDuration = 0.6
        
        updateLabel.font = .preferredFont(forTextStyle: .body)
        updateLabel.textColor = Singleton.lightGrayTextColor
        if Singleton.loadStatus == .downloading {
            updateLabel.text = "Downloading data"
            updateIcon.startAnimating()
        } else if Singleton.loadStatus == .updating {
            updateLabel.text = "Refreshing data"
            updateIcon.startAnimating()
        } else if Singleton.loadStatus == .processingDownload || Singleton.loadStatus == .processingUpdate {
            updateLabel.text = "Processing data"
            updateIcon.startAnimating()
        } else {
            updateIcon.stopAnimating()
            table.frame = CGRect(
                x: 0,
                y: semesterLabel.frame.maxY,
                width: view.frame.width,
                height: table.rowHeight * CGFloat(Singleton.schedule.count)
            )
            table.reloadData()
            let minutes = Int((NSDate.timeIntervalSinceReferenceDate - Singleton.lastUpdate)/60)
            if minutes < 1 {
                updateLabel.text = "Data updated just now"
            }else if minutes == 1 {
                updateLabel.text = "Data updated 1 minute ago"
            } else if minutes < 60 {
                updateLabel.text = "Data updated \(minutes) minutes ago"
            } else if minutes < 60*24 {
                updateLabel.text = "Data updated \(Int(minutes/60)) hours ago"
            } else {
                updateLabel.text = "Data updated \(Int(minutes/(60*24))) days ago"
            }
        }
    }
    
    func goToWebsite() {
        UIApplication.shared.open(URL(string: "http://unmcoursemate.wordpress.com")!)
    }
    
    func updateStatus() {
        guard isViewLoaded else {
            return
        }
        if Singleton.loadStatus == .downloading {
            updateLabel.text = "Downloading data"
            updateIcon.startAnimating()
        } else if Singleton.loadStatus == .updating {
            updateLabel.text = "Refreshing data"
            updateIcon.startAnimating()
        } else if Singleton.loadStatus == .processingDownload || Singleton.loadStatus == .processingUpdate {
            updateLabel.text = "Processing data"
            updateIcon.startAnimating()
        } else {
            updateIcon.stopAnimating()
            table.frame = CGRect(
                x: 0,
                y: table.frame.minY,
                width: view.frame.width,
                height: table.rowHeight * CGFloat(Singleton.schedule.count)
            )
            table.addBorder(color: .normal, sides: [.top, .bottom])
            table.reloadData()
            
            websiteLabel.frame = CGRect(
                x: 15,
                y: table.frame.maxY + 70,
                width: container.frame.width - 30,
                height: 100
            )
            
            let minutes = Int((NSDate.timeIntervalSinceReferenceDate - Singleton.lastUpdate)/60)
            if minutes < 1 {
                updateLabel.text = "Data updated just now"
            }else if minutes == 1 {
                updateLabel.text = "Data updated 1 minute ago"
            } else if minutes < 60 {
                updateLabel.text = "Data updated \(minutes) minutes ago"
            } else if minutes < 60*24 {
                updateLabel.text = "Data updated \(Int(minutes/60)) hours ago"
            } else {
                updateLabel.text = "Data updated \(Int(minutes/(60*24))) days ago"
            }
        }
    }
    
    func done() {
        delegate.refresh()
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.schedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.semester.text = Singleton.schedule[indexPath.row].semesterID
        cell.layout()
        if indexPath.row == Singleton.semesterIndex {
            cell.check.alpha = 1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        if indexPath.row != Singleton.semesterIndex {
            (table.cellForRow(at: IndexPath(row: Singleton.semesterIndex, section: 0)) as! TableCell).check.alpha = 0
            (table.cellForRow(at: indexPath) as! TableCell).check.alpha = 1
            Singleton.semesterIndex = indexPath.row
            UserDefaults.standard.set(indexPath.row, forKey: "semesterIndex")
            if indexPath.row == 1 {
                if Singleton.mySchedules.count < 2 {
                    Singleton.mySchedules.append([[Section]]())
                    Singleton.mySchedulesNames.append([String]())
                }
                if Singleton.plannedCourses.count < 2 {
                    Singleton.plannedCourses.append([PlannedCourse]())
                }
            }
        }
    }
    
    class TableCell: UITableViewCell {
        var semester = UILabel()
        var cellSize = CGSize()
        var check = UIImageView()
        var enabled = false
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = Singleton.lightGrayBackgroundColor
            contentView.addSubview(semester)
            contentView.addSubview(check)
            semester.font = .preferredFont(forTextStyle: .body)
            semester.adjustsFontSizeToFitWidth = true
            semester.minimumScaleFactor = 0.7
            check.image = #imageLiteral(resourceName: "check")
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        func layout() {
            semester.frame = CGRect(
                x: 15,
                y: 0,
                width: cellSize.width - 15 - 13 - 15,
                height: cellSize.height
            )
            
            check.frame = CGRect(
                x: cellSize.width - 28,
                y: 17,
                width: 13,
                height: 10
            )
            check.alpha = 0
        }
    }
}
