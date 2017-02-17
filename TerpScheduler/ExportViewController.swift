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

  @IBAction func doExport(_ sender: UIButton) {
    let selectedPeriod = periodSelector!.selectedSegmentIndex + 1
    let tasksForPeriod = delegate?.getTasks(selectedPeriod)
    let classData = delegate?.getClassInformation(selectedPeriod)
    let metaData = [String: String]()
    let body = createBody(fromTasks: tasksForPeriod!)
    let header = createHeader(classData!)
    let pdfData = PDFDataConvertable(metaData: metaData, headerData: header, bodyData: body)
    let pdfWriter = PDFReporter(data: pdfData, ofType: .tasksForClass)
    let url = pdfWriter.render()
    if url != nil {
      documentPresenter = UIDocumentInteractionController(url: url!)
      documentPresenter!.presentOpenInMenu(from: sender.frame, in: self.view, animated: true)
    }
  }
  weak var sharedDelegate = UIApplication.shared.delegate! as? AppDelegate
  weak var delegate: ExportDelegate?

  var documentPresenter: UIDocumentInteractionController?
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSize(width: 300, height: 200)
    delegate = sharedDelegate!.dataManager
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func createHeader(_ classData: SchoolClass) -> String {
    return "All tasks for \n \(classData.subject), period \(classData.period)"
  }

  func createBody(fromTasks tasks: [DailyTask]) -> [String: [String]] {
    var strings = [String: [String]]()
    for task in tasks {
      let key = stringFromDate(task.date as Date)
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

  func stringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yy"
    return formatter.string(from: date)
  }
}
