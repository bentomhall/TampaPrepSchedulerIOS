//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol ClassPeriodDataSource {
  func getClassData(period: Int)->SchoolClass
  func setClassData(data:SchoolClass, forIndex index:Int)
  func openWebView(url: NSURL)
}

@IBDesignable
class ClassPeriodViewController: UIViewController {
  @IBAction func openWebView(sender: UILabel){
    let v = self.view as ClassPopupView
    let url_string = v.HaikuURLInput!.text
    if url_string == "" {
      return
    }
    
    var url: NSURL
    if v.HaikuURLInput!.text.hasPrefix("http://"){
      url = NSURL(string: url_string)!
    } else{
      url = NSURL(string: "http://"+url_string)!
    }
    self.viewWillDisappear(false)
    delegate!.openWebView(url)
    self.dismissViewControllerAnimated(false, completion: nil)
  }
  var receivedClassData : SchoolClass?
  var delegate : ClassPeriodDataSource?
  var _index: Int = -1
  var index : Int {
    get { return _index }
    set(value) {
      _index = value
      receivedClassData = delegate!.getClassData(index)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let v = self.view as ClassPopupView
    v.setContent(receivedClassData!)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    let v = self.view as ClassPopupView
    let outputClassData = v.getContent()
    delegate!.setClassData(outputClassData, forIndex: index)
  }
  
}
