//: Playground - noun: a place where people can play

import UIKit

/**
优先队列
*/
struct PriorityQueue <T>{
    
    //存储队列
    private var queue:[T]!;
    
    //排序函数 T1:当前element T2:待检测element
    private var compare:(T,T)->Bool;
    
    //compare 排序函数 T1:当前element T2:待检测element;return true 互换位置 false 不予处理
    init(compare:(T,T) -> Bool)
    {
        self.compare = compare;
        queue = [];
    }
    
    //放入element
    mutating func push(element:T)
    {
        queue.append(element);
        bubbleUP(queue.count - 1);
    }
    
    //获得优先的element
    mutating func pop() -> T?
    {
        if(empty) return nil;
        let end = queue.removeLast();
        if(!empty)
        {
            let first = queue[0];
            queue[0] = end;
            sinkDown(0);
            return first;
        }
        return end;
    }
    
    //是否为空
    var empty:Bool
    {
        return queue.isEmpty;
    }
    
    //向上冒泡
    private mutating func bubbleUP(fromIndex:Int)
    {
        if(fromIndex < 1){return;}
        var index = fromIndex;
        let element = queue[index];
        while(index > 0)
        {
            let pIndex = ((index-1) >> 1);
            if(compare(queue[index], queue[pIndex])){break;}
            queue[index] = queue[pIndex];
            queue[pIndex] = element;
        }
    }
    
    //下沉
    private mutating func sinkDown(fromIndex:Int)
    {
        let len = queue.count;
        let element = queue[fromIndex];
        var index = fromIndex;
        while(true)
        {
            var currentIndex = index;
            let childIndex1 = (currentIndex << 1 + 1);
            if(childIndex1 >= len){break;}
            let childIndex2 = childIndex1 + 1;
            if(compare(queue[currentIndex], queue[childIndex1]))
            {
                currentIndex = childIndex1;
            }
            if(childIndex2 < len && compare(queue[childIndex1], queue[childIndex2]))
            {
                currentIndex = childIndex2;
            }
            
            if(currentIndex != index)
            {
                queue[index] = queue[currentIndex];
                queue[currentIndex] = element;
                index = currentIndex;
            }
            else{break;}
        }
        
    }
}

var q = PriorityQueue<Int>(){$0.0 > $0.1}
q.push(4)
q.push(0)
q.push(2)
q.push(1)
q.push(3)
q.queue;

