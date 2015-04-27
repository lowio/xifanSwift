//
//  DataManager.swift
//  TopApps
//
//  Created by Dani Arnaout on 9/2/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import Foundation

let TopAppURL = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=25/json"

class DataManager {
  
  class func getTopAppsDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      //2
      let filePath = NSBundle.mainBundle().pathForResource("TopApps",ofType:"json")
   
      var readError:NSError?
      if let data = NSData(contentsOfFile:filePath!,
        options: NSDataReadingOptions.DataReadingUncached,
        error:&readError) {
        success(data: data)
      }
    })
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