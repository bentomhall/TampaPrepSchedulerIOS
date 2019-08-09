//
//  TaskEditViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/8/19.
//  Copyright © 2019 Tampa Preparatory School. All rights reserved.
//

import Foundation

class TaskEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var detailTableView: UITableView?
    @IBOutlet weak var dateAndPeriodLabel: UILabel?
    @IBOutlet weak var titleView: UITextField?
    @IBOutlet weak var detailView: UITextView?
    @IBOutlet weak var priorityView: UISegmentedControl?
    @IBOutlet weak var isCompletedSwitch: UISwitch?
    @IBOutlet weak var isHaikuTaskSwitch: UISwitch?
    @IBOutlet weak var shouldRemindSwitch: UISwitch?
    @IBOutlet var textLabels: [UILabel]?
    
    weak var taskDelegate: (TaskDetailDelegate & TaskTableDelegate)?
    private var tasks = [DailyTask]()
    private var selectedIndex = IndexPath(row: 0, section: 0)
    var colors: UserColors?
    private var date: Date?
    private var period: Int = -1
    private var previousTask: DailyTask?
    
    @IBAction func didUpdateData(_ sender: Any) {
        save(index: selectedIndex.row)
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addTask()
    }
    
    @IBAction func didChangeTaskCompletion(_ sender: UISwitch) {
        save(index: selectedIndex.row)
        
        //detailTableView!.reloadRows(at: [index], with: .none)
    }
    
    @IBAction func didChangeNotificationStatus(_ sender: UISwitch) {
        save(index: selectedIndex.row)
        let taskData = tasks[selectedIndex.row]
        if sender.isOn {
            taskDelegate!.postNotification(forTask: taskData)
        } else {
            taskDelegate!.cancelNotificationMatching(taskData)
        }
    }
    
    func setData(date: Date, period: Int) {
        self.date = date
        self.period = period
    }
    
    @objc func userColorsDidChange() {
        DispatchQueue.main.async {
            self.detailTableView!.backgroundView?.backgroundColor = self.colors!.backgroundColor
            //self.detailTableView!.tableFooterView!.backgroundColor = self.colors!.backgroundColor
        }
        
    }
    
    override func viewDidLoad() {
        //let formatter = DateFormatter()
        //formatter.dateFormat = "MM/dd/YYYY"
        //let sDate = formatter.string(from: date ?? Date())
        //self.dateAndPeriodLabel!.text = sDate + ": period \(period)"
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userColorsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        setColorScheme()
        tasks = taskDelegate!.tasksFor(day: date!, period: period)
        if tasks.count == 0 {
            tasks.append(taskDelegate!.defaultTask)
        }
        //detailTableView!.reloadData()
        //clear()
        detailTableView!.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        selectedIndex = IndexPath(row: 0, section: 0)
        displayDetail(for: selectedIndex)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        let sDate = formatter.string(from: date ?? Date())
        self.dateAndPeriodLabel!.text = sDate + ": period \(period)"
        tasks = taskDelegate!.tasksFor(day: date!, period: period)
        detailTableView!.reloadData()
        clear()
        selectedIndex = IndexPath(row: 0, section: 0)
        displayDetail(for: selectedIndex)
        detailTableView!.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        setColorScheme()
        previousTask = taskDelegate!.defaultTask
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else {
            let defaultCell = TaskTableViewCell()
            defaultCell.setTitleText(task.shortTitle, taskIsComplete: task.isCompleted, colors: colors!)
            return defaultCell
        }
        cell.setTitleText(task.shortTitle, taskIsComplete: task.isCompleted, colors: colors!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let index = detailTableView!.indexPathForSelectedRow?.row {
            save(index: index)
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        displayDetail(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let item = tasks[(indexPath as NSIndexPath).row]
            tasks.remove(at: (indexPath as NSIndexPath).row)
            taskDelegate!.didDeleteTask(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func setColorScheme() {
        self.view.backgroundColor = colors!.backgroundColor
        self.detailTableView!.backgroundColor = colors!.backgroundColor
        for label in textLabels! {
            label.textColor = colors!.textColor
        }
        priorityView!.tintColor = colors!.textColor
    }
    
    private func displayDetail(for indexPath: IndexPath) {
        if tasks.count == 0 {
            return
        }
        let task = tasks[indexPath.row]
        titleView?.text = task.shortTitle
        detailView?.text = task.details
        priorityView?.selectedSegmentIndex = task.priority.rawValue
        isCompletedSwitch?.isOn = task.isCompleted
        isHaikuTaskSwitch?.isOn = task.isHaikuAssignment
        shouldRemindSwitch?.isOn = task.shouldNotify
    }
    
    private func clear() {
        titleView?.text = ""
        detailView?.text = ""
        priorityView?.selectedSegmentIndex = 2
        isCompletedSwitch?.isOn = false
        isHaikuTaskSwitch?.isOn = false
    }
    
    private func save(index: Int) {
        if titleView!.text != "" {
            var oldTask: DailyTask
            if index > tasks.count - 1 {
                oldTask = taskDelegate!.defaultTask
            } else {
                oldTask = tasks[index]
            }
            let shortTitle = titleView!.text
            let details = detailView!.text
            var priority = Priorities(rawValue: priorityView!.selectedSegmentIndex)
            let isHaiku = isHaikuTaskSwitch!.isOn
            let completion = isCompletedSwitch!.isOn
            let notification = shouldRemindSwitch!.isOn
            if completion {
                priority = Priorities.completed
            }
            
            let newTaskData = DailyTask(date: date!, period: period, shortTitle: shortTitle!, details: details!, isHaiku: isHaiku, completion: completion, priority: priority!, notify: notification, guid: oldTask.GUID)
    
            if newTaskData != oldTask {
                let newTask = taskDelegate!.updateTask(newTaskData, withPreviousTask: oldTask)
                reload()
                detailTableView!.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
            }
        }
    }
    
    private func addTask() {
        let nextIndex = tasks.count
        let path = IndexPath(row: nextIndex, section: 0)
        let task = taskDelegate!.defaultTask
        tasks.append(task)
        print(nextIndex)
        detailTableView!.beginUpdates()
        detailTableView!.insertRows(at: [IndexPath(row: nextIndex, section: 0)], with: .none)
        detailTableView!.endUpdates()
        //reload()
        displayDetail(for: path)
        selectedIndex = path
        detailTableView!.selectRow(at: IndexPath(row: nextIndex, section: 0), animated: true, scrollPosition: .middle)
    }
    
    private func reload() {
        tasks = taskDelegate!.tasksFor(day: date!, period: period)
        detailTableView!.reloadData()
    }
    
}

extension TaskEditViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        save(index: selectedIndex.row)
    }
}

extension TaskEditViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        save(index: selectedIndex.row)
    }
}
