//
//  RunTest.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation
import xlib;

func testPriorityQueue()
{
    var q = XPriorityQueue<Int>(){$0.0 > $0.1}
    
    for i in 0...500
    {
        let temp = Int(arc4random() % 1000);
//        let temp = i;
        q.push(temp);
    }
    
    while(!q.empty)
    {
        q.pop();
//        println(q.pop());
    }

}


func testJsonParser()
{
    JsonLoader.getTopAppsDataFromFileWithSuccess(){
        (jsd) -> Void in
        let jsonParser = XJSON(data: jsd);
        let d = jsonParser["feed"]["author"]["uri"]["label"] as XJSON
//        let d = jsonParser["feed"]["author"] as JSONParser
        let v = d.stringValue
        println(d)
        println(v)
    };
}
