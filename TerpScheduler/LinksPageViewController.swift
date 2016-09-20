//
//  LinksPageViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/25/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class LinksPageViewController: UIViewController {

  @IBOutlet weak var tampaPrepButton: UIButton?
  @IBOutlet weak var myBackPackButton: UIButton?
  @IBOutlet weak var haikuLearningButton: UIButton?
  @IBOutlet weak var googleDriveButton: UIButton?
  @IBOutlet weak var backButton: UIButton?
  
  let tampaPrepURL = URL(string: "http://www.tampaprep.org")!
  let myBackPackURL = URL(string: "https://tampaprep.seniormbp.com/SeniorApps")!
  let haikuAppURL = URL(string: "haikulearning://")!
  let haikuURL = URL(string: "https://tampaprep.haikulearning.com")!
  let googleDriveAppURL = URL(string: "googledrive://")!
  
  @IBAction func linkButtonPressed(_ sender: UIButton){
    var url: URL
    switch(sender.titleLabel!.text!){
    case "Tampa Prep":
      url = tampaPrepURL
      break
    case "My Backpack":
      url = myBackPackURL
      break
    case "Haiku Learning":
      if UIApplication.shared.canOpenURL(haikuAppURL){
        url = haikuAppURL
      } else {
        url = haikuURL
      }
      break
    case "Google Drive":
      if UIApplication.shared.canOpenURL(googleDriveAppURL) {
        url = googleDriveAppURL
      } else {
        url = URL(string: "http://drive.google.com")!
      }
      break
    default:
      url = URL(string: "http://www.google.com")!
      break
    }
    UIApplication.shared.openURL(url)
  }
  
  @IBAction func closeView(_ sender: UIButton){
    dismiss(animated: true, completion: nil)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ExportTasks"{
      let receivingController = segue.destination as! ExportViewController
      receivingController.modalPresentationStyle = .popover
      receivingController.preferredContentSize = CGSize(width: 300, height: 300)
    }
  }
}
