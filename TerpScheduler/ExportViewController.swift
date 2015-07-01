//
//  ExportViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 3/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController, UIDocumentInteractionControllerDelegate {
  @IBOutlet var periodSelector: UISegmentedControl?
  
  @IBAction func doExport(sender: UIButton){
    let selectedPeriod = periodSelector!.selectedSegmentIndex + 1
    let tasksForPeriod = delegate.getTasks(selectedPeriod)
    let classData = delegate.getClassInformation(selectedPeriod)
    let metaData = [String: String]()
    let body = createBody(fromTasks: tasksForPeriod)
    let header = createHeader(classData)
    let pdfData = PDFDataConvertable(metaData: metaData, headerData: header, bodyData: body)
    let pdfWriter = PDFReporter(data: pdfData, ofType: .TasksForClass)
    let url = pdfWriter.render()
    if url != nil {
      documentPresenter = UIDocumentInteractionController(URL: url!)
      documentPresenter!.presentOpenInMenuFromRect(sender.frame, inView: self.view, animated: true)
    }
  }
  
  let delegate: ExportDelegate = (UIApplication.sharedApplication().delegate! as! AppDelegate).dataManager
  var documentPresenter: UIDocumentInteractionController?
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSizeMake(300, 200)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func createHeader(classData: SchoolClass)->String{
    return "All tasks for \n \(classData.subject), period \(classData.period)"
  }
  
  func createBody(fromTasks tasks: [DailyTask])->[String: [String]]{
    var strings = [String: [String]]()
    for task in tasks {
      let key = stringFromDate(task.date)
      let temporaryString = "\(task.shortTitle) Priority: \(task.priority.rawValue) \n Details: \(task.details) \n Turn in on Haiku? \(task.isHaikuAssignment) \n Completed? \(task.isCompleted)"
      var currentValue = strings[key]
      if currentValue != nil {
        currentValue!.append(temporaryString)
      } else {
        currentValue = [temporaryString]
      }
      strings[key] = currentValue!
    }
    return strings
  }
  
  func stringFromDate(date: NSDate)->String{
    var formatter = NSDateFormatter()
    formatter.dateFormat = "MM/dd/yy"
    return formatter.stringFromDate(date)
  }
}
