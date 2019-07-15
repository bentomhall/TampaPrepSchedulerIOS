//
//  LinksPageViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/25/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol UpdateNotificationDelegate: class {
  func scheduleUpdateDidComplete(status: scheduleUpdateStatus)
  func scheduleUpdateCheckWillBegin()
}

enum scheduleUpdateStatus {
  case NewScheduleDownloaded
  case UpToDate
  case Error(text: String)
}

func standardStringFromDate(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  return formatter.string(from: date)
}

class LinksPageViewController: UIViewController, UpdateNotificationDelegate {

  @IBOutlet weak var tampaPrepButton: UIButton?
  @IBOutlet weak var myBackPackButton: UIButton?
  @IBOutlet weak var haikuLearningButton: UIButton?
  @IBOutlet weak var googleDriveButton: UIButton?
  @IBOutlet weak var backButton: UIButton?
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
  @IBOutlet weak var updateScheduleButton: UIButton?
  @IBOutlet weak var updateResultLabel: UILabel?
  
  weak var colors: UserColors?

  let tampaPrepURL = URL(string: "http://www.tampaprep.org")!
  let myBackPackURL = URL(string: "https://tampaprep.seniormbp.com/SeniorApps")!
  let haikuAppURL = URL(string: "haikulearning://")!
  let haikuURL = URL(string: "https://tampaprep.haikulearning.com")!
  let googleDriveAppURL = URL(string: "googledrive://")!
  var updateController: ScheduleUpdateController?

  @IBAction func linkButtonPressed(_ sender: UIButton) {
    var url: URL
    switch sender.titleLabel!.text! {
    case "Tampa Prep":
      url = tampaPrepURL
      break
    case "My Backpack":
      url = myBackPackURL
      break
    case "Haiku Learning":
      if UIApplication.shared.canOpenURL(haikuAppURL) {
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
    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
  }
  
  @IBAction func doNetworkUpdate(_ sender: UIButton) {
    updateController = ScheduleUpdateController(notificationDelegate: self)
    updateController!.willUpdateFromNetwork()
    scheduleUpdateCheckWillBegin()
  }

  @IBAction func closeView(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }

    override func viewDidLoad() {
      super.viewDidLoad()
      activityIndicator!.hidesWhenStopped = true
      setColorScheme()
        // Do any additional setup after loading the view.
    }
  
  func setColorScheme() {
    self.view.backgroundColor = colors!.backgroundColor
    tampaPrepButton!.tintColor = colors!.secondaryThemeColor
    myBackPackButton!.tintColor = colors!.secondaryThemeColor
    haikuLearningButton!.tintColor = colors!.secondaryThemeColor
    googleDriveButton!.tintColor = colors!.secondaryThemeColor
    backButton!.tintColor = colors!.primaryThemeColor
    updateScheduleButton!.tintColor = colors!.secondaryThemeColor
    activityIndicator!.color = colors!.primaryThemeColor
    updateResultLabel?.textColor = colors!.textColor
  }
  
  func scheduleUpdateDidComplete(status: scheduleUpdateStatus) {
    DispatchQueue.main.async {
      switch status {
      case .NewScheduleDownloaded:
        self.updateResultLabel!.text = "Schedule updated"
        break
      case .UpToDate:
        self.updateResultLabel!.text = "Schedule up to date"
        break
      case .Error(let errorText):
        self.updateResultLabel!.text = "An error occurred: \(errorText)"
        break
      }
      self.updateResultLabel!.textAlignment = .center
      self.activityIndicator!.stopAnimating()
    }
  }
  
  func scheduleUpdateCheckWillBegin() {
    activityIndicator!.startAnimating()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ExportTasks"{
      if let receivingController = segue.destination as? ExportViewController {
      receivingController.modalPresentationStyle = .popover
      receivingController.preferredContentSize = CGSize(width: 300, height: 300)
      }
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
