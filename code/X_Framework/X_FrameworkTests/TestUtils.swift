//
//  TestUtils.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
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
    
    static func loadLocalData(fileName:String, _ ofType:String, _ success:(NSData?) -> ())
    {
        let p = self.bundle.pathForResource(fileName, ofType: ofType);
        
        do{
            let data = try NSData(contentsOfFile: p!, options: NSDataReadingOptions.DataReadingUncached);
            success(data);
        }
        catch {
            print("loadLocalData error file:\(fileName).\(ofType)");
        }
    }
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
}