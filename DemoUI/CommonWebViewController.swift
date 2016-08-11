//
//  CommonWebViewController.swift
//  DemoUI
//
//  Created by wizard lee on 8/11/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

class CommonWebViewController: UIViewController {
//    private var
    private var minTime:Int64 = INT64_MAX
    private var maxTime:Int64 = 0
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func go(sender: UIButton) {
        MyURLProtocol.enable = false
        MyURLProtocol.statisticDelegate = self
        textField.resignFirstResponder()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: textField.text!)!))
    }
    
    @IBAction func showStatics(sender: UIButton) {
        print("cost : \(maxTime - minTime)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CommonWebViewController: MyURLProtocolStatics {
    func urlDidLoad(url: String) {
        let currentTime = Int64(NSDate.timeIntervalSinceReferenceDate() * 1000)
        if maxTime < currentTime {
            maxTime = currentTime
        }
    }
    
    func urlDidStart(url: String) {
        let currentTime = Int64(NSDate.timeIntervalSinceReferenceDate() * 1000)
        if minTime > currentTime {
            minTime = currentTime
        }
    }
}
