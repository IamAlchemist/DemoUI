//
//  MyURLProtocol.swift
//  DemoUI
//
//  Created by wizard lee on 8/9/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit
import CoreData


protocol MyURLProtocolStatics: class {
    func urlDidStart(url : String)
    func urlDidLoad(url : String)
}

class MyURLProtocol: NSURLProtocol, NSURLConnectionDelegate {
    
    static weak var statisticDelegate : MyURLProtocolStatics?
    static var enable = true
    
    var session: NSURLSession!
    var mutableData: NSMutableData!
    var response: NSURLResponse!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        if NSURLProtocol.propertyForKey("MyURLProtocolHandledKey", inRequest: request) != nil {
            return false
        }
        
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest,
                                                 toRequest bRequest: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    override func startLoading() {
        MyURLProtocol.statisticDelegate?.urlDidStart(request.URL!.absoluteString)
        
        if let cachedResponse = cachedResponseForCurrentRequestConcurrent()
//        if let cachedResponse = cachedResponseForCurrentRequest()
            where MyURLProtocol.enable {
            print("Serving from cache : \(request.URL!.absoluteString), \(NSThread.currentThread().description)")
            
            let data = cachedResponse.valueForKey("data") as! NSData
            let mimeType = cachedResponse.valueForKey("mimeType") as! String?
            let encoding = cachedResponse.valueForKey("encoding") as! String?
            
            let response = NSURLResponse(URL: request.URL!, MIMEType: mimeType, expectedContentLength: data.length, textEncodingName: encoding)
            client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
            client!.URLProtocol(self, didLoadData: data)
            client!.URLProtocolDidFinishLoading(self)
            
            MyURLProtocol.statisticDelegate?.urlDidLoad(request.URL!.absoluteString)
        }
        else {
            print("Load url :\(request.URL!.absoluteString), \(NSThread.currentThread().description)")
            let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
            NSURLProtocol.setProperty(true, forKey: "MyURLProtocolHandledKey", inRequest: newRequest)
        
            session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
            let task = session.dataTaskWithRequest(newRequest)
            task.resume()
        }
    }
    
    override func stopLoading() {
        if let session = session {
            session.invalidateAndCancel()
        }
    }
    
    func saveCachedResponse () {
        guard let urlString = request.URL?.absoluteString else {
            print("could not get url string")
            return
        }
        
        // 1
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        // 2
        context.performBlock {
            let cachedResponse = NSEntityDescription.insertNewObjectForEntityForName("CachedURLResponse", inManagedObjectContext: context) as NSManagedObject
            
            cachedResponse.setValue(self.mutableData, forKey: "data")
            cachedResponse.setValue(urlString, forKey: "url")
            cachedResponse.setValue(NSDate(), forKey: "timestamp")
            cachedResponse.setValue(self.response.MIMEType, forKey: "mimeType")
            cachedResponse.setValue(self.response.textEncodingName, forKey: "encoding")
            
            // 3
            do {
                try context.save()
            } catch {
                print("could not save response")
            }
        }
    }
    
    func saveCachedResponseConcurrent() {
        guard let urlString = request.URL?.absoluteString else {
            print("could not get url string")
            return
        }
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.getCurrentManagedObjectContext()
        
        let cachedResponse = NSEntityDescription.insertNewObjectForEntityForName("CachedURLResponse", inManagedObjectContext: context) as NSManagedObject
        
        cachedResponse.setValue(self.mutableData, forKey: "data")
        cachedResponse.setValue(urlString, forKey: "url")
        cachedResponse.setValue(NSDate(), forKey: "timestamp")
        cachedResponse.setValue(self.response.MIMEType, forKey: "mimeType")
        cachedResponse.setValue(self.response.textEncodingName, forKey: "encoding")
        
        delegate.saveThreadContext(context)
    }
    
    func cachedResponseForCurrentRequestConcurrent() -> NSManagedObject? {
        guard let urlString = request.URL?.absoluteURL else { return nil }
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.getCurrentManagedObjectContext()
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("CachedURLResponse", inManagedObjectContext: context)
        fetchRequest.entity = entity
        
        let predicate = NSPredicate(format:"url == %@", urlString)
        fetchRequest.predicate = predicate
        
        do {
            guard let result = try context.executeFetchRequest(fetchRequest) as? Array<NSManagedObject> else { return nil }
            
            if !result.isEmpty {
                return result[0];
            }
        }
        catch {
            print("could not load cache")
        }
        
        return nil
    }
    
    func cachedResponseForCurrentRequest() -> NSManagedObject? {
        
        guard let urlString = request.URL?.absoluteURL else { return nil }
        
        // 1
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        // 2
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("CachedURLResponse", inManagedObjectContext: context)
        fetchRequest.entity = entity
        
        // 3
        let predicate = NSPredicate(format:"url == %@", urlString)
        fetchRequest.predicate = predicate
        
        // 4
        do {
            guard let result = try context.executeFetchRequest(fetchRequest) as? Array<NSManagedObject> else { return nil }
            
            if !result.isEmpty {
                return result[0];
            }
        }
        catch {
            print("could not load cache")
        }
        
        return nil
    }
}

extension MyURLProtocol: NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        print("download")
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeStreamTask streamTask: NSURLSessionStreamTask) {
        print("strem")
    }
}

extension MyURLProtocol: NSURLSessionDelegate {
}

extension MyURLProtocol: NSURLSessionDownloadDelegate {
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("download finish")
    }
}

extension MyURLProtocol: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        self.response = response
        mutableData = NSMutableData()
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            client?.URLProtocol(self, didFailWithError: error)
        }
        else {
            client?.URLProtocolDidFinishLoading(self)
            MyURLProtocol.statisticDelegate?.urlDidLoad(request.URL!.absoluteString)
            if MyURLProtocol.enable {
                saveCachedResponseConcurrent()
//                saveCachedResponse()
            }
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        client?.URLProtocol(self, didLoadData: data)
        mutableData.appendData(data)
    }
}