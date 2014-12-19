//
//  ViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
        let direction = recognizer.direction
        switch (direction)
        {
            case UISwipeGestureRecognizerDirection.Left:
                break
                //open side pane
            case UISwipeGestureRecognizerDirection.Right:
                break
                //close side pane if open
            case UISwipeGestureRecognizerDirection.Up:
                //previous week
                break
            case UISwipeGestureRecognizerDirection.Down:
                //next week
                break
            default:
                //do nothing
                break
        }
    }


}

