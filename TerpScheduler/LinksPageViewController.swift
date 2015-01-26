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
  
  let tampaPrepURL = NSURL(string: "http://www.tampaprep.org")!
  let myBackPackURL = NSURL(string: "https://tampaprep.seniormbp.com/SeniorApps")!
  let haikuAppURL = NSURL(string: "haikulearning://")!
  let haikuURL = NSURL(string: "https://tampaprep.haikulearning.com")!
  let googleDriveAppURL = NSURL(string: "googledrive://")!
  
  @IBAction func linkButtonPressed(sender: UIButton){
    var url: NSURL
    switch(sender.titleLabel!.text!){
    case "Tampa Prep":
      url = tampaPrepURL
      break
    case "My Backpack":
      url = myBackPackURL
      break
    case "Haiku Learning":
      if UIApplication.sharedApplication().canOpenURL(haikuAppURL){
        url = haikuAppURL
      } else {
        url = haikuURL
      }
      break
    case "Google Drive":
      url = googleDriveAppURL
      break
    default:
      url = NSURL(string: "http://www.google.com")!
      break
    }
    UIApplication.sharedApplication().openURL(url)
  }
  
  @IBAction func closeView(sender: UIButton){
    dismissViewControllerAnimated(true, completion: nil)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
