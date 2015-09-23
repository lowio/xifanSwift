//
//  JsonTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit

func commonTest() {
//    jsonTest()
    priorityQueueTest();
}

//XPriorityQueue test
func priorityQueueTest(testRebuild:Bool = false)
{
    var queue:XPriorityQueue<Int>;
    if(testRebuild)//测试创建优先队列
    {
        var sortArray = [Int]();
        for _ in 0...100
        {
            sortArray.append(Int(arc4random() % 1000));
        }
        queue = XPriorityQueue<Int>(sequence: sortArray){$0.0 >= $0.1};
        sortArray.sortInPlace{$0 > $1}
        while !queue.isEmpty
        {
            let e1 = queue.pop()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2) ");
        }
    }
    else
    {   //测试优先队列效率
        queue = XPriorityQueue<Int>{$0 >= $1}
        let c = 100;
        for _ in 0...c
        {
            let temp = Int(arc4random() % 500);
            if(!queue.isEmpty){queue.pop();}
            
            for _ in 0...3
            {
                queue.push(temp);
            }
        }
        
        while(!queue.isEmpty)
        {
            let e = queue.pop()!;
            print(e)
        }
    }
    
}

///test xjson
func jsonTest()
{
    TestUtils.loadLocalData("TopApps", "json"){
        if let jsd = $0{
            let jsonParser = XJSON(data: jsd);
            let d = jsonParser["feed"]["author"]["uri"]["label"] as XJSON
            //                let d = jsonParser["feed"]["author"] as XJSON
            let v = d.stringValue;
            print(d,v)
        }
        
    }
}
