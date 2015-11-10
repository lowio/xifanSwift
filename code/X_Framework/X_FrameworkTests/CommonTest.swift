//
//  JsonTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
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
//    var nd = Array2D<Int?>(columns: columns, rows: rows, repeatValue: 0);
    var nd = Array2D<Int>(columns: columns, rows: rows, repeatValue: 0);
    print(nd);
    var i = 0;
    for r in 0..<rows
    {
        for c in 0..<columns
        {
            nd[c, r] = i++;
        }
    }
    print(nd);
    print(nd.count)
    nd[1, 1] = 99;
//    nd[3, 2] = nil;
    
    let p = nd.positionOf{
        return 99 == $0
    }
    print(nd, p);
//    nd = Array2D<Int>(columns: nd.columns, rows: nd.rows, repeatValue: 0, values: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]);
    nd = Array2D<Int>(columns: nd.columns, rows: nd.rows, repeatValue: 0, values: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    nd[3,2] = 99;
    print(nd);
    
    
    let a = Array<Int>(nd);
    print(a);
}
private func createPQ(source:Array<Int>? = nil) -> BinaryPriorityQueue<Int>
{
    return BinaryPriorityQueue<Int>(source: source ?? [], isOrderedBefore:{return $0 < $1});
}

//XPriorityQueue test
//old impl best:                    average: 0.088 -- MAC mini, insert: 4000 popBest: 4000
//BinaryPriorityQueue<Int>          average: 0.100 -- MAC mini, insert: 4000 popBest: 4000
//BinaryPriorityQueue<Int>          average: 0.200 -- MAC air,  insert: 4000 popBest: 4000
func priorityQueueTest(testRebuild:Bool = false)
{
    var queue:BinaryPriorityQueue<Int>;
    
    
    if(testRebuild)//测试创建优先队列
    {
        var sortArray:[Int] = [];
        
        queue = createPQ();
        for _ in 0...100
        {
            sortArray.append(random());
        }
        
        queue = createPQ(sortArray);
        
        
        sortArray.sortInPlace({$0 > $1})
        while !queue.isEmpty
        {
            let e1 = queue.popBest()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2)  count:\(queue.count)");
        }
        
    }
    else
    {
        //测试优先队列效率
        queue = createPQ();
        var count = 4000;
        let i = count;
        repeat{
            queue.insert(count);
            count--;
        }while count > 0;
//        print(queue.indexOf(1));
//        print(queue);
//        return;
        var a = 0;
        repeat{
            let e = queue.popBest()!;
//            print("current:", e, "last:", a, "current-last=", e - a);
            a = e;
        }
        while !queue.isEmpty
        print("insert: \(i) popBest: \(i)" , a);
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
