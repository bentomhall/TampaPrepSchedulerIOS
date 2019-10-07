//
//  JumpToDateViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 4/25/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class JumpToDateViewController: UIViewController, UIPopoverPresentationControllerDelegate {

  func initialize(dataManager: DataManager) {
    self.dataManager = dataManager
    self.popoverPresentationController?.delegate = self
  }

  @IBOutlet weak var datePicker: UIDatePicker?
  var dataManager: (TaskSummaryDelegate & DateInformationDelegate)?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bounds = dataManager!.dateBounds()
        datePicker!.minimumDate = bounds.0
        datePicker!.maximumDate = bounds.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func viewWillDisappear(_ animated: Bool) {
    let selectedDate = datePicker!.date
    dataManager!.loadWeek(selectedDate)
  }

  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    let selectedDate = datePicker!.date
    dataManager!.loadWeek(selectedDate)
  }

}
