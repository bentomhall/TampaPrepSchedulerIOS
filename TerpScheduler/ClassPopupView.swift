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
    @IBOutlet var TitleLabel : UILabel?
    @IBOutlet var isStudyHall : UISwitch?
    @IBOutlet var TeacherNameInput : UITextField?
    @IBOutlet var SubjectNameInput : UITextField?
    @IBOutlet var HaikuURLInput : UITextField?
    @IBAction func ToggleStudyHall(sender : UIView){
        if let s = sender as? UISwitch {
            if s.on {
                TeacherNameInput!.enabled = false
                SubjectNameInput!.text! = "Study Hall"
                SubjectNameInput!.enabled = false
                TeacherNameInput!.text = ""
            }
            else {
                TeacherNameInput!.enabled = true
                SubjectNameInput!.enabled = true
                TeacherNameInput!.text! = ""
                SubjectNameInput!.text! = ""
            }
        }
    }
    
    var classPeriod = -1
    
    func setContent(data:ClassPeriodData){
        classPeriod = data.ClassPeriod
        TitleLabel!.text! = "Period \(classPeriod)"
        if data.IsStudyHall {
            isStudyHall!.setOn(true, animated: false)
            TeacherNameInput!.enabled = false
            SubjectNameInput!.text! = "Study Hall"
            SubjectNameInput!.enabled = false
        }
        else {
            isStudyHall!.setOn(false, animated: false)
            TeacherNameInput!.text! = data.TeacherName
            SubjectNameInput!.text! = data.Subject
        }
        if let url = data.HaikuURL? {
        HaikuURLInput!.text! = url.description
        }
        else {
        HaikuURLInput!.text! = ""
        }
    }
    
    func getContent()->ClassPeriodData{
        var haikuURL : NSURL?
        let teacher = TeacherNameInput!.text
        let subject = SubjectNameInput!.text
        let studyHall = isStudyHall!.on
        let HaikuURLText = HaikuURLInput!.text
        if HaikuURLText != "" {
            haikuURL = NSURL(string: HaikuURLText)
        }
        let outputClassData = ClassPeriodData(ClassPeriod: classPeriod, TeacherName: teacher, HaikuURL: haikuURL, IsStudyHall: studyHall, Subject: subject)
        return outputClassData
    }
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
