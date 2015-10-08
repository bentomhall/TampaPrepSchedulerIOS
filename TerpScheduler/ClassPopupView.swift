//
//  ClassPopupView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/13/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class ClassPopupView: UIView {
  @IBOutlet var titleLabel : UILabel?
  @IBOutlet var isStudyHall : UISwitch?
  @IBOutlet var teacherNameInput : UITextField?
  @IBOutlet var subjectNameInput : UITextField?
  @IBOutlet var haikuURLInput : UITextField?
  @IBOutlet var classLockSwitch: UISwitch?
  @IBOutlet weak var haikuButton: UIButton?
  
  @IBAction func toggleStudyHall(sender : UIView){
    if let s = sender as? UISwitch {
      if s.on {
        teacherNameInput!.enabled = false
        subjectNameInput!.text! = "Study Hall"
        subjectNameInput!.enabled = false
        teacherNameInput!.text = ""
      }
      else {
        teacherNameInput!.enabled = true
        subjectNameInput!.enabled = true
        teacherNameInput!.text! = ""
        subjectNameInput!.text! = ""
      }
    }
  }
  
  @IBAction func toggleLock(sender: UISwitch){
    if sender.on {
      teacherNameInput!.enabled = false
      subjectNameInput!.enabled = false
      haikuURLInput!.enabled = false
    } else {
      teacherNameInput!.enabled = true
      subjectNameInput!.enabled = true
      haikuURLInput!.enabled = true
    }
    isLocked = sender.on
  }
  
  var classPeriod = -1
  var isLocked: Bool = false
  var receivedData: SchoolClass?
  
  func setContent(data: SchoolClass){
    receivedData = data
    classPeriod = data.period
    titleLabel!.text! = "Period \(classPeriod)"
    if data.isStudyHall {
      isStudyHall!.setOn(true, animated: false)
      teacherNameInput!.enabled = false
      subjectNameInput!.text! = "Study Hall"
      subjectNameInput!.enabled = false
    }
    else {
      isStudyHall!.setOn(false, animated: false)
      teacherNameInput!.text! = data.teacherName
      subjectNameInput!.text! = data.subject
    }
    if let url = data.haikuURL {
      haikuURLInput!.text! = url.absoluteString
    }
    else {
      haikuURLInput!.text! = ""
    }
    isLocked = data.isLocked
    classLockSwitch!.setOn(isLocked, animated: false)
    if isLocked {
      toggleLock(classLockSwitch!)
    }
  }
  
  func getContent()->SchoolClass{
    var haikuURL : NSURL?
    let teacher = teacherNameInput!.text ?? ""
    let subject = subjectNameInput!.text ?? ""
    let studyHall = isStudyHall!.on
    let HaikuURLText = haikuURLInput!.text ?? ""
    if HaikuURLText != "" {
      haikuURL = NSURL(string: HaikuURLText)
    }
    let outputClassData = SchoolClass(period: classPeriod, teacherName: teacher, haikuURL: haikuURL, isStudyHall: studyHall, subject: subject, isLocked: isLocked, id: receivedData!.id)
    return outputClassData
  }
}
