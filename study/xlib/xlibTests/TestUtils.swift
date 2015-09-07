//
//  JsonTest.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation


class TestUtils {
    
    private static var _bundle:NSBundle?;
    
    private static var bundle:NSBundle{
        if let b = _bundle
        {
            return b;
        }
        _bundle = NSBundle(forClass: self);
        return _bundle!;
    }
    
    class func getTopAppsDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        let filePath = self.bundle.pathForResource("TopApps",ofType:"json")
        
        var readError:NSError?
        if let data = NSData(contentsOfFile:filePath!,
            options: NSDataReadingOptions.DataReadingUncached,
            error:&readError) {
                success(data: data)
        }
    }
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
}