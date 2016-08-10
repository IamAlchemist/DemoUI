//
//  MyURLProtocol.swift
//  DemoUI
//
//  Created by wizard lee on 8/9/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit
import CoreData

var requestCount = 0

class MyURLProtocol: NSURLProtocol, NSURLConnectionDelegate {
    
    var session: NSURLSession!
    var mutableData: NSMutableData!
    var response: NSURLResponse!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        if NSURLProtocol.propertyForKey("MyURLProtocolHandledKey", inRequest: request) != nil {
            return false
        }
        
        print("Request #\(requestCount): URL = \(request.URL?.absoluteString ?? "empty url")")
        requestCount += 1
        
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
        let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "MyURLProtocolHandledKey", inRequest: newRequest)
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(newRequest)
        task.resume()
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
        
        print("save \(requestCount - 1): \(urlString)")
        // 1
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        // 2
        let cachedResponse = NSEntityDescription.insertNewObjectForEntityForName("CachedURLResponse", inManagedObjectContext: context) as NSManagedObject
        
        cachedResponse.setValue(mutableData, forKey: "data")
        cachedResponse.setValue(urlString, forKey: "url")
        cachedResponse.setValue(NSDate(), forKey: "timestamp")
        cachedResponse.setValue(response.MIMEType, forKey: "mimeType")
        cachedResponse.setValue(response.textEncodingName, forKey: "encoding")
        
        // 3
        do {
            try context.save()
        } catch {
            print("could not save response")
        }
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
            saveCachedResponse()
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        client?.URLProtocol(self, didLoadData: data)
        mutableData.appendData(data)
    }
}