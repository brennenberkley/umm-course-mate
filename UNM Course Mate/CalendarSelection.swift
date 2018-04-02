import Foundation
import UIKit
import EventKit

class CalendarSelection: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var calendars: [EKCalendar]!
    let table = UITableView()
    var scheduleIndex: Int!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationItem.title = "Select a Calendar"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        let backItem = UIBarButtonItem(title: "Calendar", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let container = UIView()
        container.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        view.addSubview(container)
        
        calendars = EKEventStore().calendars(for: .event)
        calendars.sort(by: { $0.title < $1.title })
        
        var i = 0
        while i < calendars.count {
            if !calendars[i].allowsContentModifications {calendars.remove(at: i)}
            i = i + 1
        }
        
        container.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        table.rowHeight = 44
        table.separatorInset.left = 42
        table.register(TableCell.self, forCellReuseIdentifier: "cell")
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableCell
        cell.cellSize = CGSize(width: table.frame.width, height: table.rowHeight)
        cell.layout()
        
        if indexPath.row < calendars.count {
            let calendarColor = calendars[indexPath.row].cgColor
            cell.color.backgroundColor = UIColor(cgColor: calendarColor)
            cell.name.text = calendars[indexPath.row].title
        } else {
            cell.color.backgroundColor = .clear
            cell.name.text = "Create new calendar"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < calendars.count {
            let review = ExportSchedule()
            review.calendars = calendars
            review.scheduleIndex = scheduleIndex
            review.calendarIndex = indexPath.row
            navigationController!.pushViewController(review, animated: true)
        } else { // create new calendar
            let destination = NewCalendar()
            destination.calendars = calendars
            destination.scheduleIndex = scheduleIndex
            destination.calendarIndex = indexPath.row
            navigationController!.pushViewController(destination, animated: true)
        }
    }
    
    class TableCell: UITableViewCell {
        var color = UIView()
        var name = UILabel()
        var cellSize = CGSize()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(color)
            contentView.addSubview(name)
            name.font = .preferredFont(forTextStyle: .body)
            name.adjustsFontSizeToFitWidth = true
            name.minimumScaleFactor = 0.7
            color.frame = CGRect(
                x: 10,
                y: 11,
                width: 22,
                height: 22
            )
            color.layer.cornerRadius = 3
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            
            name.frame = CGRect(
                x: color.frame.maxX + 10,
                y: 0,
                width: cellSize.width - (color.frame.maxX + 10) - 10,
                height: cellSize.height
            )
        }
    }
}
