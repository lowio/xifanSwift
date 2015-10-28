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

private func createPQ(source:Array<Int>? = nil) -> PriorityArray<Int>
{
    return PriorityArray<Int>(isOrderedBefore:{return $0 < $1}, source:source);
}

//XPriorityQueue test
//PriorityArray<Int> average: 0.168 -- MAC air, 4000 insert 4000 popBest
func priorityQueueTest(testRebuild:Bool = false)
{
    var queue:PriorityArray<Int>;
    if(testRebuild)//测试创建优先队列
    {
        var sortArray = [999];
        for _ in 0...100
        {
            sortArray.append(random());
        }
        
        queue = createPQ(sortArray);
//        let index = queue.indexOf(999);
//        let index2 = queue.indexOf{return $0 == 999;}
//        print(index, index2);
        
        print(queue)
        sortArray.sortInPlace({$0 > $1})
        while !queue.isEmpty
        {
            let e1 = queue.popBest()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2)  count:\(queue.count)");
        }
        
    }
    else
    {   //测试优先队列效率
        queue = createPQ();
        let count = 400;
        var total = count;
        var i = 0;
        repeat{
            
            for _ in 0...9
            {
                queue.insert(total * 100 + 10000);
                i++;
            }
            
            queue.popBest();
            
            total--;
        }while total > 0
        
        repeat{
            queue.popBest();
        }while !queue.isEmpty;
        print("insert: \(i) popBest: \(i)");
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
