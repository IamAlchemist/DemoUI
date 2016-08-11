//
//  BrowserViewController.swift
//  NSURLProtocolExample
//
//  Created by Zouhair Mahieddine on 7/10/14.
//  Copyright (c) 2014 Zedenem. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController, UITextFieldDelegate {
    
    private var minTime:Int64 = INT64_MAX
    private var maxTime:Int64 = 0
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    
    //MARK: IBAction
    
    @IBAction func buttonGoClicked(sender: UIButton) {
        MyURLProtocol.enable = true
        MyURLProtocol.statisticDelegate = self

        if self.textField.isFirstResponder() {
            self.textField.resignFirstResponder()
        }
        
        self.sendRequest()
    }
    
    @IBAction func statistic(sender: UIButton) {
        print("cost : \(maxTime - minTime)")
    }
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.sendRequest()
        
        return true
    }
    
    //MARK: Private
    
    func sendRequest() {
        if let text = self.textField.text {
            let url = NSURL(string:text)
            let request = NSURLRequest(URL:url!)
            self.webView.loadRequest(request)
        }
    }
}

extension BrowserViewController: MyURLProtocolStatics {
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


