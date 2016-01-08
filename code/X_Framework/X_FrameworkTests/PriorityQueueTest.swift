//
//  PriorityQueueTest.swift
//  X_Framework
//
//  Created by 173 on 15/12/18.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation
@testable import X_Framework;


typealias PQ = PriorityQueue<Int>;


//XPriorityQueue test
func priorityQueueTest(testRebuild:Bool = false, testReplace: Bool = false)
{
    var queue: PQ;
    
    guard !testReplace else {
        let arr = [0, 2, 3, 1, 9, 6, 8, 7];
        queue = PQ(minimum: arr);
        print(queue.source);
        queue.replace(-1, at: 4);
        print(queue.source);
        while !queue.isEmpty
        {
            let e1 = queue.popBest()!;
            print(e1);
        }
        return;
    }
    
    guard !testRebuild else{
        var sortArray:[Int] = [];
        
        for _ in 0...100
        {
            sortArray.append(random());
        }
        
        queue = PQ(minimum: sortArray);
        
        sortArray.sortInPlace({$0 > $1})
        while !queue.isEmpty
        {
            let e1 = queue.popBest()!;
            let e2 = sortArray.removeLast();
            print("\(e1)-\(e2)=\(e1 - e2)  count:\(queue.count)");
        }
        return;
    }
    
    queue = PQ(minimum: []);
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
//        print("current:", e, "last:", a, "current-last=", e - a);
        a = e;
    }
        while !queue.isEmpty
    print("insert: \(i) popBest: \(i)" , a);
}