//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;

private func singleTest(start: PFPosition2D, goal: PFPosition2D, map: TestMap, visited: (([PFPosition2D:PFPosition2D]) -> ())?){
    
}

func pathFinderTest(markVisited: Bool = true, markPath: Bool = true) {
    let start = PFPosition2D(x: 17, y: 17);
    let goals = [PFPosition2D(x: 7, y: 7), PFPosition2D(x: 7, y: 27), PFPosition2D(x: 27, y: 27), PFPosition2D(x: 27, y: 7)];
    
//    let goals = [PFPosition2D(x: 30, y: 14)]
    let map = TestMap(heristic: .Euclidean, passMode: .Diagonal);
    let finder = BreadthBestPathFinder<TestMap>();
//    let finder = DijkstraPathFinder<TestMap>();
    var visited: [PFPosition2D:PFPosition2D]?;
    guard let path = (finder.execute(start, goals: goals, request: map)
//        {
//            visited = $0;
//        }
    )else {
        print("WARN: ========= NO WAY!!!");
        return;
    }
//    return;
    
    var conf = Array2D(columns: map.size, rows: map.size, repeatValue: "✅");
    
    if let v = visited{
        for (p, pp) in v{
            let arrow = TestArrow.getArrow(p.x, y1: p.y, x2: pp.x, y2: pp.y).description;
            conf[p.x, p.y] = arrow;
        }
    }
    
    for ps in path{
        var last: PFPosition2D?;
        for p in ps{
            guard let lt = last else{
                last = p;
                continue;
            }
            last = p;
            let arrow = TestArrow.getArrow(p.x, y1: p.y, x2: lt.x, y2: lt.y).description;
            conf[p.x, p.y] = arrow;
        }
    }
    conf[start.x, start.y] = "🚹";
    for g in goals{
        conf[g.x , g.y] = "🚺";
    }
    print(conf);
    
    
    //CGflaot 比 Int 快？
    //实现协议后 实现协议中已经实现的方法效率会高很多
    
    //具体文章：Enum链表 自定义一个2dgenerator
    
    //    jump point search
    //    dic不可取 效率太低 想其他办法 index ...
    //    diagoanl算法有问题
    //    load map config json 格式的
}


struct TestMap{
    let config: Array2D<Int>;
    
    let size: Int;
    
    let heuristic: PFinderHuristic2D;
    
    let passMode: PFinderPassMode2D;
    
    
    init(heristic: PFinderHuristic2D, passMode: PFinderPassMode2D = .Straight, _ s: Int = 35){
        var c = Array2D(columns: s, rows: s, repeatValue: 1);
//        c[17, 17] = 0;
//        c[16, 17] = 0;
//        c[18, 17] = 0;
        self.size = s;
        self.config = c;
        self.heuristic = heristic;
        self.passMode = passMode;
    }
}
extension TestMap: PathFinderRequestType{
    //return neighbors(passable) of position
    func neighborsOf(position: PFPosition2D) -> [PFPosition2D]{
        var arr: [PFPosition2D] = [];
        let ns = passMode.neighborsOffset();
        ns.forEach{
            let op = $0;
            let x = op.0 + position.x;
            let y = op.1 + position.y;
            guard config.columns > x && x > -1 && y > -1 && config.rows > y else {return;}
            let cst = config [x, y];
            guard cst > 0 else {return;}
            arr.append(PFPosition2D(x: x, y: y));
        }
        return arr;
    }
    
    //return cost between position and toPosition
    func costOf(position: PFPosition2D, _ toPosition: PFPosition2D) -> CGFloat {
        return CGFloat(config[toPosition.x, toPosition.y]);
    }
    
    //return h value between position and toPosition
    func heuristicOf(position: PFPosition2D, _ toPosition: PFPosition2D) -> CGFloat {
        return self.heuristic.heuristicOf(position, toPosition);
    }
}