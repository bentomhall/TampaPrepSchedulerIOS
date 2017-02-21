//
//  WebViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/24/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
  @IBOutlet weak var webView: UIWebView?
  var initialURL: URL?

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    var request: URLRequest?
    if initialURL != nil {
      request = URLRequest(url: initialURL!)
    }
    webView!.loadRequest(request!)
  }
}
