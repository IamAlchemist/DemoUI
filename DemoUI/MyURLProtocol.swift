//
//  MyURLProtocol.swift
//  DemoUI
//
//  Created by wizard lee on 8/9/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

var requestCount = 0

class MyURLProtocol: NSURLProtocol {
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        print("Request #\(requestCount): URL = \(request.URL?.absoluteString ?? "empty url")")
        requestCount += 1
        return false
    } 
}