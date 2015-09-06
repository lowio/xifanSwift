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
    var q = XPriorityQueue<Int>(){$0.0 < $0.1}
    let c = 100;
    
//    var arr = [Int]();
//    for i in 0...14
//    {
//        arr.append(Int(arc4random() % 1000));
//    }
//    println(arr);
//    q.rebuild(arr);
//    println(q)
//    while(!q.isEmpty)
//    {
//        println(q.pop());
//    }
    
    
    for i in 0...c
    {
//        let temp = Int(arc4random() % 1000);
        let temp = i;
        let e = q.pop();
//        println(e);
        for j in 0...3
        {
            q.push(temp);
        }
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
