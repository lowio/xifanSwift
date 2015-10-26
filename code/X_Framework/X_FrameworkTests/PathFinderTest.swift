//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;



func pathFinderTest() {
    
    let size = 50;
    let config = Array2D<Int>(columns: size, rows: size, repeatValue: 1);
    let queue = FinderBreadthFirstQueue<FinderElement<Point2D>>();
    let dataSource = FinderDataSource2D<Point2D>(config: config, diagonal: false);
    let heuristic = FinderHuristic2D<Point2D>.Manhattan;
    let start = Point2D(x: 24, y: 24, cost: 1);
    let goal = Point2D(x: 13, y: 13, cost: 1);
    let finder = OFinder<FinderElement<Point2D>>();
    
    var tempConfig = Array2D<String>(columns: size, rows: size, repeatValue: "@");
    var path:[Point2D] = [];
    finder.find(start, goal: goal, dataSource: dataSource, finderQueue: queue, heuristic: heuristic, completion: {
        path = $0;
        }){
            for v in $0{
                tempConfig[v.x, v.y] = "+";
            }
            for v in path
            {
                tempConfig[v.x, v.y] = "*";
            }
            tempConfig[start.x , start.y] = "$"
            tempConfig[goal.x, goal.y] = "¥";
        }
    
    
    print(tempConfig);
    //    jump point search
    //    dic不可取 效率太低 想其他办法 index ...
    //    diagoanl算法有问题
    //    load map config json 格式的
    //    改变compare方法后打印visited看看变化
    //    优化visited和closed存储方式
    //    其它：优化算法 添加alpha值用于配置算法趋向Dijkstra还是Best-First-Search根据结果打印
}