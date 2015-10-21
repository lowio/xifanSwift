//
//  JsonTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;

func commonTest() {
//    jsonTest()
    priorityQueueTest();
//    arrayNDTest();
}

func arrayNDTest()
{
    let columns = 4;
    let rows = 3;
//    var nd = Array2D<Int>(columns: columns, rows: rows);
    var nd =  Dictionary2D<Int>(columns: columns, rows: rows);
    var i = 0;
    for r in 0..<rows
    {
        for c in 0..<columns
        {
            nd[c, r] = i++;
        }
    }
    
    print(nd);
    
    nd[1, 1] = 99;
//    nd = Array2D<Int>(columns: nd.columns, rows: nd.rows, values: nd.toCollection());
    nd = Dictionary2D<Int>(columns: nd.columns, rows: nd.rows, values: [0, nil, 20]);
    print(nd);
    print(nd.positionOf(99), nd.positionOf(-1));
    
    let p = nd.positionOf(99){return $0 == $1;}
    print(p);
    
    print(nd.toCollection())
}

//XPriorityQueue test
func priorityQueueTest(testRebuild:Bool = true)
{
    var queue:PriorityArray<Int>;
    if(testRebuild)//测试创建优先队列
    {
        var sortArray = [Int]();
        for _ in 0...100
        {
            sortArray.append(random());
        }
        
        queue = PriorityArray<Int>(source: sortArray){$0 < $1};
        sortArray.sortInPlace({$0 > $1})
        while !queue.isEmpty
        {
            let e1 = queue.popFirst()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2)  count:\(queue.count)");
        }
    }
    else
    {   //测试优先队列效率
        queue = PriorityArray<Int>{$0 < $1}
        let c = 400;
        for _ in 0...c
        {
            let temp = Int(arc4random() % 500);
            if(!queue.isEmpty){queue.popFirst();}
            
            for _ in 0...3
            {
                queue.append(temp);
            }
        }
        
        while(!queue.isEmpty)
        {
            let e = queue.popFirst()!;
            print(e)
        }
    }
    
}

///test xjson
func jsonTest()
{
//    TestUtils.loadLocalData("TopApps", "json"){
//        if let jsd = $0{
//            let jsonParser = XJSON(data: jsd);
//            let d = jsonParser["feed"]["author"]["uri"]["label"] as XJSON
//            //                let d = jsonParser["feed"]["author"] as XJSON
//            let v = d.stringValue;
//            print(d,v)
//        }
//        
//    }
}
