import Foundation
import UIKit
import EventKit

class NewCalendar: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var calendars: [EKCalendar]!
    var nameBox = UITextField()
    let table = UITableView()
    var scheduleIndex: Int!
    var calendarIndex: Int!
    var colors = [UIColor]()
    var colorNames = [String]()
    var calendarName: String!
    var selectedColor = 0
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationItem.title = "Create a New Calendar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
        
        let backItem = UIBarButtonItem(title: "Calendar", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        colorNames.append("Red")
        colors.append(UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        
        colorNames.append("Orange")
        colors.append(UIColor(red: 1, green: 0.6, blue: 0, alpha: 1))
        
        colorNames.append("Yellow")
        colors.append(UIColor(red: 1, green: 0.9, blue: 0, alpha: 1))
        
        colorNames.append("Green")
        colors.append(UIColor(red: 0, green: 0.9, blue: 0, alpha: 1))
        
        colorNames.append("Blue")
        colors.append(UIColor(red: 0.4, green: 0.6, blue: 1, alpha: 1))
        
        colorNames.append("Purple")
        colors.append(UIColor(red: 0.8, green: 0.3, blue: 0.8, alpha: 1))
        
        colorNames.append("Brown")
        colors.append(UIColor(red: 0.6, green: 0.3, blue: 0.3, alpha: 1))
        
        container.addSubview(nameBox)
        nameBox.delegate = self
        nameBox.backgroundColor = Singleton.lightGrayBackgroundColor
        nameBox.placeholder = "Calendar Name"
        nameBox.autocapitalizationType = .words
        nameBox.autocorrectionType = .yes
        nameBox.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: 44))
        nameBox.leftViewMode = .always
        nameBox.frame = CGRect(
            x: 0,
            y: 30,
            width: container.frame.width,
            height: 44
        )
        nameBox.addBorder(color: .normal, sides: [.top, .bottom])
        
        let colorsLabel = UILabel()
        container.addSubview(colorsLabel)
        colorsLabel.text = "color"
        colorsLabel.font = .preferredFont(forTextStyle: .body)
        colorsLabel.textColor = Singleton.lightGrayTextColor
        colorsLabel.sizeToFit()
        colorsLabel.frame = CGRect(
            x: 21,
            y: nameBox.frame.maxY + 20,
            width: colorsLabel.frame.width,
            height: colorsLabel.frame.height
        )
        
        container.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 44
        table.frame = CGRect(
            x: 0,
            y: colorsLabel.frame.maxY + 2,
            width: container.frame.width,
            height: CGFloat(colors.count)*table.rowHeight - 1/UIScreen.main.scale
        )
        table.addBorder(color: .normal, sides: [.top, .bottom])
        table.separatorInset.left = 42
        table.isScrollEnabled = false
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
    }
    
    func nextPage() {
        let review = ExportSchedule()
        review.calendars = calendars
        review.scheduleIndex = scheduleIndex
        review.calendarIndex = calendarIndex
        if nameBox.text == "" {
            review.newCalendarName = "Classes"
        } else {
            review.newCalendarName = nameBox.text!
        }
        review.newCalendarColor = colors[selectedColor]
        navigationController!.pushViewController(review, animated: true)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameBox.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.isEnabled = true
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.color = colors[indexPath.row]
        cell.name.text = colorNames[indexPath.row]
        cell.layout()
        if indexPath.row == 0 {
            cell.check.alpha = 1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameBox.endEditing(true)
        table.deselectRow(at: indexPath, animated: true)
        (table.cellForRow(at: IndexPath(row: selectedColor, section: 0)) as! TableCell).check.alpha = 0
        (table.cellForRow(at: indexPath) as! TableCell).check.alpha = 1
        selectedColor = indexPath.row
    }
    
    class TableCell: UITableViewCell {
        var colorView = UIView()
        var name = UILabel()
        var cellSize = CGSize()
        var check = UIImageView()
        var enabled = false
        var color: UIColor!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = Singleton.lightGrayBackgroundColor
            contentView.addSubview(colorView)
            contentView.addSubview(name)
            contentView.addSubview(check)
            name.font = .preferredFont(forTextStyle: .body)
            name.adjustsFontSizeToFitWidth = true
            name.minimumScaleFactor = 0.7
            colorView.frame = CGRect(
                x: 10,
                y: 11,
                width: 22,
                height: 22
            )
            colorView.layer.cornerRadius = 3
            check.image = #imageLiteral(resourceName: "check")
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            colorView.backgroundColor = color
        }
        
        func layout() {
            colorView.backgroundColor = color
            
            name.frame = CGRect(
                x: colorView.frame.maxX + 10,
                y: 0,
                width: cellSize.width - colorView.frame.maxX - 63,
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
