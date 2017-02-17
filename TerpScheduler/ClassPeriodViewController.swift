//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol ClassPeriodDataSource: class {
  func getClassData(_ period: Int) -> SchoolClass
  func setClassData(_ data: SchoolClass, forIndex index: Int)
  func openWebView(_ url: URL)
  func shouldShadeRow(_: Bool, forPeriod: Int)
}

@IBDesignable
class ClassPeriodViewController: UIViewController {
  @IBAction func openWebView(_ sender: UILabel) {
    guard let v = self.view as? ClassPopupView else {
      return
    }
    let url_string = v.haikuURLInput!.text
    var url: URL
    if url_string == "" {
      url = URL(string: "https://tampaprep.haikulearning.com")!
    } else if url_string!.hasPrefix("https://") {
      url = URL(string: url_string!)!
    } else {
      url = URL(string: "http://"+url_string!)!
    }
    saveData()
    self.dismiss(animated: false, completion: nil)
    delegate!.openWebView(url)
  }

  var receivedClassData: SchoolClass?
  weak var delegate: ClassPeriodDataSource?
  var classIndex: Int = -1
  var index: Int {
    get { return classIndex }
    set(value) {
      classIndex = value
      receivedClassData = delegate!.getClassData(classIndex)
    }
  }

  func saveData() {
    guard let v = self.view as? ClassPopupView else {
      return
    }
    let outputClassData = v.getContent()
    delegate!.setClassData(outputClassData, forIndex: index)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let v = self.view as? ClassPopupView else {
      return
    }
    v.setContent(receivedClassData!)
    if receivedClassData!.isStudyHall {
      delegate!.shouldShadeRow(true, forPeriod: index + 1)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveData()
  }

}
