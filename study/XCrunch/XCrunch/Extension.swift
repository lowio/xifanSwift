//
//  Extension.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

extension JSONParser
{
    static func create(fileName:String, directory:String) -> JSONParser?
    {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json", inDirectory: directory)
        {
            var error:NSError?
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                return JSONParser(data: data);
            } catch let error1 as NSError {
                error = error1
            }
        }
        print("can not find \(fileName)");
        return nil;
    }
}

extension Dictionary
{
    //加载json文件
    static func loadJSONData(fileName:String) -> Dictionary<String, AnyObject>?
    {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json", inDirectory: "Levels")
        {
            var error:NSError?
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                if let dic: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    where dic is Dictionary<String, AnyObject>
                {
                    return dic as? Dictionary<String, AnyObject>;
                }
                else
                {
                    print("file is not json type, error:\(error)");
                    return nil;
                }
            } catch let error1 as NSError {
                error = error1
                print("can not load \(fileName), error:\(error)");
                return nil;
            }
        }
        
        print("can not find \(fileName)");
        return nil;
    }
}