//
//  WebViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/24/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate{
  @IBOutlet weak var webView: UIWebView?
  var initialURL: NSURL?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    var request: NSURLRequest?
    if initialURL != nil {
      request = NSURLRequest(URL: initialURL!)
    }
    webView!.loadRequest(request!)
  }
}
