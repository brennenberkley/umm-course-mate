import Foundation
import UIKit
import EventKit

protocol FilterProtocol {
    func updateTimes(date: Date)
    func updateDays(days: [Bool])
    func updateOnline(online: Bool)
    func updateFull(full: Bool)
}

class FilterSchedules: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterProtocol {
    
    var delegate: CreateScheduleProtocol!
    let container = UIView()
    var label = UILabel()
    var table = UITableView()
    var pickerRow = 0
    var pickerIsVisible = false
    var earliestTime: Date?
    var latestTime: Date?
    var availableDays = [false, true, true, true, true, true, false] // S, M, T, W, T, F, S
    var includeOnline = true
    var includeFull = false
    var time8: Date!
    var time5: Date!
    var possibleSchedules = [[ScheduleSection]]()
    var conflictingCourses: [ScheduleSection]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Create Schedule"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
        
        let backItem = UIBarButtonItem(title: "Filter", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        container.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height,
            width: view.frame.width,
            height: view.frame.height - (UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height)
        )
        view.addSubview(container)
        
        container.addSubview(label)
        container.addSubview(table)
        
        label.backgroundColor = .white
        label.text = "Filter class times"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(
            x: 20,
            y: 0,
            width: container.frame.width - 40,
            height: 120
        )
        
        table.delegate = self
        table.dataSource = self
        table.register(TimesCell.self, forCellReuseIdentifier: "times")
        table.register(DaysCell.self, forCellReuseIdentifier: "days")
        table.register(PickerCell.self, forCellReuseIdentifier: "picker")
        table.register(SwitchCell.self, forCellReuseIdentifier: "switch")
        table.tableFooterView = UIView()
        table.rowHeight = 44
        table.separatorInset.left = 10
        table.isScrollEnabled = false
        table.frame = CGRect(
            x: 0,
            y: label.frame.maxY,
            width: container.frame.width,
            height: container.frame.height - label.frame.height
        )
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        time8 = formatter.date(from: "08:00")
        time5 = formatter.date(from: "17:00")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndex = table.indexPathForSelectedRow {
            table.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    func checkTableHeight() {
        var height: CGFloat!
        if pickerIsVisible {
            height = 469
        } else {
            height = 277
        }
        if height > table.frame.height {
            table.isScrollEnabled = true
        } else {
            table.isScrollEnabled = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //start and end times, days
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = Singleton.grayDividerColor
        header.frame = CGRect(
            x: 0,
            y: 0,
            width: table.frame.width,
            height: 1/UIScreen.main.scale
        )
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1/UIScreen.main.scale
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if pickerIsVisible {
                return 5
            } else {
                return 4
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if pickerIsVisible && indexPath.row == pickerRow {
                return 192
            } else {
                return 44
            }
        } else { //days
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if pickerIsVisible {
                if indexPath.row == 0 {
                    let cell = table.dequeueReusableCell(withIdentifier: "times") as! TimesCell
                    cell.label.text = "Earliest Time"
                    cell.value.text = "none"
                    cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    cell.layout()
                    return cell
                } else if indexPath.row == 1 {
                    if pickerRow == 1 {
                        let cell = table.dequeueReusableCell(withIdentifier: "picker") as! PickerCell
                        cell.cellSize = CGSize(width: table.frame.width, height: 192)
                        cell.delegate = self
                        cell.backgroundColor = Singleton.lightGrayBackgroundColor
                        cell.layout()
                        return cell
                    } else {
                        let cell = table.dequeueReusableCell(withIdentifier: "times") as! TimesCell
                        cell.label.text = "Latest Time"
                        cell.value.text = "none"
                        cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
                        cell.backgroundColor = Singleton.lightGrayBackgroundColor
                        cell.layout()
                        return cell
                    }
                } else if indexPath.row == 2{
                    if pickerRow == 2 {
                        let cell = table.dequeueReusableCell(withIdentifier: "picker") as! PickerCell
                        cell.cellSize = CGSize(width: table.frame.width, height: 192)
                        cell.delegate = self
                        cell.backgroundColor = Singleton.lightGrayBackgroundColor
                        cell.layout()
                        return cell
                    } else {
                        let cell = table.dequeueReusableCell(withIdentifier: "times") as! TimesCell
                        cell.label.text = "Latest Time"
                        cell.value.text = "none"
                        cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
                        cell.backgroundColor = Singleton.lightGrayBackgroundColor
                        cell.layout()
                        return cell
                    }
                } else if indexPath.row == 3 { // online
                    let cell = table.dequeueReusableCell(withIdentifier: "switch") as! SwitchCell
                    cell.cellSize = CGSize(width: container.frame.width, height: 44)
                    cell.delegate = self
                    cell.label.text = "Include online classes"
                    cell.cellType = "online"
                    cell.layout()
                    cell.selectionStyle = .none
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    return cell
                } else { // full sections
                    let cell = table.dequeueReusableCell(withIdentifier: "switch") as! SwitchCell
                    cell.cellSize = CGSize(width: container.frame.width, height: 44)
                    cell.delegate = self
                    cell.label.text = "Include full sections"
                    cell.cellType = "full"
                    cell.layout()
                    cell.selectionStyle = .none
                    cell.separatorInset.left = table.frame.width
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    return cell
                }
            } else { //picker not visible
                if indexPath.row == 0 {
                    let cell = table.dequeueReusableCell(withIdentifier: "times") as! TimesCell
                    cell.label.text = "Earliest Time"
                    cell.value.text = "none"
                    cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    cell.layout()
                    return cell
                } else if indexPath.row == 1 {
                    let cell = table.dequeueReusableCell(withIdentifier: "times") as! TimesCell
                    cell.label.text = "Latest Time"
                    cell.value.text = "none"
                    cell.cellSize = CGSize(width: container.frame.width, height: table.rowHeight)
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    cell.layout()
                    return cell
                } else if indexPath.row == 2 { // online
                    let cell = table.dequeueReusableCell(withIdentifier: "switch") as! SwitchCell
                    cell.cellSize = CGSize(width: container.frame.width, height: 44)
                    cell.delegate = self
                    cell.label.text = "Include online classes"
                    cell.cellType = "online"
                    cell.layout()
                    cell.selectionStyle = .none
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    return cell
                } else { // full sections
                    let cell = table.dequeueReusableCell(withIdentifier: "switch") as! SwitchCell
                    cell.cellSize = CGSize(width: container.frame.width, height: 44)
                    cell.delegate = self
                    cell.label.text = "Include full sections"
                    cell.cellType = "full"
                    cell.layout()
                    cell.selectionStyle = .none
                    cell.separatorInset.left = table.frame.width
                    cell.backgroundColor = Singleton.lightGrayBackgroundColor
                    return cell
                }
            }
        } else { //days section
            let cell = table.dequeueReusableCell(withIdentifier: "days") as! DaysCell
            cell.cellSize = CGSize(width: container.frame.width, height: 100)
            cell.delegate = self
            cell.layout()
            cell.selectionStyle = .none
            cell.separatorInset.left = table.frame.width
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row != (table.numberOfRows(inSection: 0) - 1) {
            table.deselectRow(at: indexPath, animated: true)
            if pickerIsVisible {
                if indexPath.row < 3 {
                    insertPicker(selectedRow: indexPath.row)
                }
            } else {
                if indexPath.row < 2 {
                    insertPicker(selectedRow: indexPath.row)
                }
            }
        }
        checkTableHeight()
    }
    
    func insertPicker(selectedRow: Int) {
        if selectedRow == 0 {
            if pickerIsVisible {
                if pickerRow == 1 {
                    pickerIsVisible = false
                    (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PickerCell).picker.removeFromSuperview()
                    table.beginUpdates()
                    table.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                    table.endUpdates()
                    if earliestTime != nil {
                        (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = .black
                    } else {
                        (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = Singleton.lightGrayTextColor
                    }
                } else {
                    pickerRow = 1
                    (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PickerCell).picker.removeFromSuperview()
                    table.beginUpdates()
                    table.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                    table.insertRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                    table.endUpdates()
                    let picker = (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PickerCell).picker
                    if let time = earliestTime {
                        picker.setDate(time, animated: false)
                    } else {
                        picker.setDate(time8, animated: false)
                    }
                    (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = Singleton.mainAppColor
                    if latestTime != nil {
                        (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! TimesCell).value.textColor = .black
                    } else {
                        (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! TimesCell).value.textColor = Singleton.lightGrayTextColor
                    }
                }
            } else {
                pickerIsVisible = true
                pickerRow = 1
                table.beginUpdates()
                table.insertRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                table.endUpdates()
                let picker = (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PickerCell).picker
                if let time = earliestTime {
                    picker.setDate(time, animated: false)
                } else {
                    picker.setDate(time8, animated: false)
                }
                (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = Singleton.mainAppColor
            }
        } else if selectedRow == 1 {
            if pickerIsVisible {
                pickerIsVisible = false
                (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PickerCell).picker.removeFromSuperview()
                table.beginUpdates()
                table.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                table.endUpdates()
                if latestTime != nil {
                    (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! TimesCell).value.textColor = .black
                } else {
                    (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! TimesCell).value.textColor = Singleton.lightGrayTextColor
                }
            } else {
                pickerIsVisible = true
                pickerRow = 2
                table.beginUpdates()
                table.insertRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                table.endUpdates()
                (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! TimesCell).value.textColor = Singleton.mainAppColor
                let picker = (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PickerCell).picker
                if let time = latestTime {
                    picker.setDate(time, animated: false)
                } else {
                    picker.setDate(time5, animated: false)
                }
            }
        } else { // row 2
            if pickerIsVisible {
                pickerRow = 2
                (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PickerCell).picker.removeFromSuperview()
                table.beginUpdates()
                table.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
                table.insertRows(at: [IndexPath(row: 2, section: 0)], with: .middle)
                table.endUpdates()
                let picker = (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PickerCell).picker
                if let time = latestTime {
                    picker.setDate(time, animated: false)
                } else {
                    picker.setDate(time5, animated: false)
                }
                if earliestTime != nil {
                    (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = .black
                } else {
                    (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! TimesCell).value.textColor = Singleton.lightGrayTextColor
                }
                (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! TimesCell).value.textColor = Singleton.mainAppColor
            }
        }
    }
    
    func updateTimes(date: Date) {
        let hour = NSCalendar.current.component(.hour, from: date)
        let minute = NSCalendar.current.component(.minute, from: date)
        var minuteText = "\(minute)"
        if minute < 10 {
            minuteText = "0\(minute)"
        }
        var time = "\(hour):\(minuteText) AM"
        if hour == 12 {
            time = "\(hour):\(minuteText) PM"
        } else if hour > 12 {
            time = "\(hour - 12):\(minuteText) PM"
        }
        (table.cellForRow(at: IndexPath(row: pickerRow - 1, section: 0)) as! TimesCell).value.text = time
        if pickerRow == 1 {
            earliestTime = date
        } else {
            latestTime = date
        }
    }
    
    func updateDays(days: [Bool]) {
        availableDays = days
    }
    
    func updateOnline(online: Bool) {
        includeOnline = online
    }
    
    func updateFull(full: Bool) {
        includeFull = full
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
        delegate.closedModal(done: false)
    }
    
    func nextPage() {
        let destination = SelectSchedule()
        destination.possibleSchedules = possibleSchedules
        destination.earliestTime = earliestTime
        destination.latestTime = latestTime
        destination.availableDays = availableDays
        destination.includeOnline = includeOnline
        destination.includeFull = includeFull
        destination.delegate = delegate
        navigationController?.pushViewController(destination, animated: true)
    }
    
    class TimesCell: UITableViewCell {
        
        var label = UILabel()
        var value = UILabel()
        var cellSize: CGSize!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(label)
            contentView.addSubview(value)
            
            label.font = .preferredFont(forTextStyle: .body)
            value.font = .preferredFont(forTextStyle: .body)
            value.textAlignment = .right
            value.textColor = Singleton.lightGrayTextColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            label.frame = CGRect(
                x: 10,
                y: 0,
                width: (cellSize.width - 30) * 0.5,
                height: cellSize.height
            )
            value.frame = CGRect(
                x: label.frame.maxX + 10,
                y: 0,
                width: (cellSize.width - 30) * 0.5,
                height: cellSize.height
            )
        }
    }
    
    class PickerCell: UITableViewCell {
        
        var cellSize: CGSize!
        var picker = UIDatePicker()
        var delegate: FilterProtocol!
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            picker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
            picker.datePickerMode = .time
            picker.minuteInterval = 5
            picker.backgroundColor = Singleton.lightGrayBackgroundColor
        }
        
        func valueChanged() {
            delegate.updateTimes(date: picker.date)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            picker.frame = CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height)
            contentView.addSubview(picker)
        }
    }
    
    class SwitchCell: UITableViewCell {
        
        var cellSize: CGSize!
        var label = UILabel()
        var slider = UISwitch()
        var delegate: FilterProtocol!
        var cellType: String! //online, full
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(label)
            contentView.addSubview(slider)
            label.font = .preferredFont(forTextStyle: .body)
            //slider.tintColor = Singleton.mainAppColor
            slider.onTintColor = Singleton.mainAppColor
            slider.addTarget(self, action: #selector(toggle), for: .valueChanged)
            slider.sizeToFit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            slider.frame = CGRect(
                x: cellSize.width - slider.frame.width - 10,
                y: (cellSize.height - slider.frame.height)/2,
                width: slider.frame.width,
                height: slider.frame.height
            )
            label.frame = CGRect(
                x: 10,
                y: 0,
                width: cellSize.width - 20,
                height: cellSize.height
            )
            if cellType == "online" {
                slider.isOn = true
            }
        }
        
        func toggle(sender: UIButton) {
            if cellType == "online" {
                delegate.updateOnline(online: slider.isOn)
            } else if cellType == "full" {
                delegate.updateFull(full: slider.isOn)
            }
        }
    }
    
    class DaysCell: UITableViewCell {
        
        var cellSize: CGSize!
        var label = UILabel()
        var buttons = [UIButton]()
        var circles = [UIImageView]()
        var values = [false, true, true, true, true, true, false]
        var days = ["S", "M", "T", "W", "T", "F", "S"]
        var delegate: FilterProtocol!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            for i in 0...6 {
                buttons.append(UIButton())
                buttons[i].setTitle(days[i], for: .normal)
                buttons[i].setTitleColor(.white, for: .normal)
                buttons[i].addTarget(self, action: #selector(toggle), for: .touchUpInside)
                contentView.addSubview(buttons[i])
                circles.append(UIImageView(image: #imageLiteral(resourceName: "grayCircle")))
                buttons[i].addSubview(circles[i])
            }
            contentView.addSubview(label)
            label.text = "Days"
            label.font = .preferredFont(forTextStyle: .title3)
            label.textAlignment = .center
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layout() {
            label.frame = CGRect(
                x: 10,
                y: 5,
                width: cellSize.width - 20,
                height: 30
            )
            for i in 0...6 {
                buttons[i].frame = CGRect(
                    x: (cellSize.width / 7) * CGFloat(i),
                    y: label.frame.maxY,
                    width: cellSize.width / 7,
                    height: 60
                )
                circles[i].frame = CGRect(
                    x: ((cellSize.width / 7) - 30)/2,
                    y: 15,
                    width: 30,
                    height: 30
                )
                if values[i] {
                    circles[i].image = #imageLiteral(resourceName: "redCircle")
                }
            }
        }
        
        func toggle(sender: UIButton) {
            let day = buttons.index(of: sender)!
            if values[day] {
                circles[day].image = #imageLiteral(resourceName: "grayCircle")
                values[day] = false
            } else {
                circles[day].image = #imageLiteral(resourceName: "redCircle")
                values[day] = true
            }
            delegate.updateDays(days: values)
        }
    }
}
