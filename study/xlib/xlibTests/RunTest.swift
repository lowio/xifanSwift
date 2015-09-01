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
    var q = XPriorityQueue<(Int, Int)>(){$0.0.0 > $0.1.0}
    
    for i in 0...499
    {
        let temp = Int(arc4random() % 100);
//        let temp = 1;
        q.push((temp, i));
    }
    
    while(!q.empty)
    {
        println(q.pop());
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
