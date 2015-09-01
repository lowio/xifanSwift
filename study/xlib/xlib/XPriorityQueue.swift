//
//  PriorityQueue.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation



/**
优先队列
*/
struct XPriorityQueue <T> :Printable{
    
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
        if(empty){ return nil; }
        let first = queue[0];
        let end = queue.removeLast();
        if(!empty)
        {
            queue[0] = end;
            sinkDown(0);
        }
        return first;
    }
    
    //是否为空
    var empty:Bool {
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
            if(compare(element, queue[pIndex])){break;}
            queue[index] = queue[pIndex];
            queue[pIndex] = element;
            index = pIndex;
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
            if(compare(element, queue[childIndex1]))
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
    
    var description:String{
        return queue.description;
    }
}