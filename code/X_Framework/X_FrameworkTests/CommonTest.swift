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
//    priorityQueueTest();
    arrayNDTest();
}

func arrayNDTest(horizontal:Bool = false)
{
    var nd = horizontal ? XArray2D<Int>(columnFirst: 4, rows: 3) : XArray2D<Int>(rowFirst: 4, rows: 3);
    print(nd);
    
    for i in 0..<nd.count
    {
        nd[i] = i;
    }
    print(nd);
    
}

//XPriorityQueue test
func priorityQueueTest(testRebuild:Bool = true)
{
    var queue:XPriorityQueue<Int>;
    if(testRebuild)//测试创建优先队列
    {
        var sortArray = [Int]();
        for _ in 0...100
        {
            sortArray.append(Int(arc4random() % 1000));
        }
        queue = XPriorityQueue<Int>(source: sortArray){$0.0 >= $0.1};
        sortArray.sortInPlace{$0 > $1}
        while !queue.isEmpty
        {
            let e1 = queue.pop()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2)  count:\(queue.count)");
        }
    }
    else
    {   //测试优先队列效率
        queue = XPriorityQueue<Int>{$0 >= $1}
        let c = 400;
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
//            print(e)
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
