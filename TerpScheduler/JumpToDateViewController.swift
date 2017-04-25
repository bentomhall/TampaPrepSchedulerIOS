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

  func initialize(dataManager: DataManager)
  {
    self.dataManager = dataManager
    self.popoverPresentationController?.delegate = self
  }
  
  @IBOutlet weak var datePicker: UIDatePicker?
  var dataManager: DataManager? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    let selectedDate = datePicker!.date
    dataManager!.loadWeek(selectedDate)
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
