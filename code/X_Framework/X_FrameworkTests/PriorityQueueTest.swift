//
//  PriorityQueueTest.swift
//  X_Framework
//
//  Created by 173 on 15/12/18.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation
@testable import X_Framework;


//typealias PQ = PriorityArray<Int>;
typealias PQ = PriorityArray2<Int>;

//XPriorityQueue test
func priorityQueueTest(testRebuild:Bool = false)
{
    var queue: PQ;
    
    if(testRebuild)//测试创建优先队列
    {
        var sortArray:[Int] = [];
        
        for _ in 0...100
        {
            sortArray.append(random());
        }
        
        queue = PQ(source: sortArray){$0 < $1;}
//        queue = PQ(sortArray){$0 < $1;}
        
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
        queue = PQ(){$0 < $1}
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