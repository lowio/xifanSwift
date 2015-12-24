//
//  FinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;


//typealias PF2 = BreadthBestPathFinder<FinderPoint2D>
typealias PF2 = DijkstraPathFinder<FinderPoint2D>
//typealias PF = GreedyBestFinder<FinderPoint2D, FinderHeuristic2D>
typealias PF = AstarFinder<FinderPoint2D, FinderHeuristic2D>

func pathFinderTest(markVisited: Bool = true, markPath: Bool = true, isDiagnal: Bool = false, multiGoals: Bool = true) {
    let size = 35;
    let conf = Array2D(columns: size, rows: size, repeatValue: 1);

    let h = FinderHeuristic2D.Euclidean;
    let m: FinderModel2D = isDiagnal ? .Diagonal : .Straight;
    

    let start = FinderPoint2D(x: 17, y: 17);
    let goals = [FinderPoint2D(x: 0, y: 0), FinderPoint2D(x: 34, y: 0), FinderPoint2D(x: 0, y: 34), FinderPoint2D(x: 34, y: 34)];
//    let goals = [FinderPoint2D(x: 7, y: 7), FinderPoint2D(x: 7, y: 27), FinderPoint2D(x: 27, y: 27), FinderPoint2D(x: 27, y: 7)];
    let goal = goals[0];
    
    let source = TestFinderDataSource(conf: conf, m);
    var path: [FinderPoint2D: [FinderPoint2D]] = [:];
    var visited: [FinderPoint2D: FinderPoint2D]
    if multiGoals {
        var finder = PF2();
        path = finder.find(from: goals, to: start, source: source);
//        visited = finder.backtraceRecord();
    }
    else{
        var finder = PF(heuristic: h);
        path = finder.find(from: start, to: goal, source: source);
//        visited = finder.backtraceRecord();
    }
    
    
    guard markPath else {return;}
    
    var printMap = Array2D(columns: size, rows: size, repeatValue: "✅");
//    if markVisited{
//        visited.forEach{
//            let point = $0;
//            let parentpoint = $1;
//            let arrow = TestArrow.getArrow(point.x, y1: point.y, x2: parentpoint.x, y2: parentpoint.y).description;
//            printMap[point.x , point.y] = arrow;
//        }
//    }
    
    path.forEach{
        let _ = $0
        let ps = $1;
        ps.forEach{
            let p = $0;
            let arrow = "📍";
            printMap[p.x, p.y] = arrow;
        }
    }
    printMap[start.x, start.y] = "🚹";
    
    for g in goals{
        printMap[g.x , g.y] = "🚺";
        guard multiGoals else{break;}
    }
    
    print(printMap);
}


struct TestFinderDataSource{
    let config: Array2D<Int>;
    
    let model: FinderModel2D;
    
    
    init(conf: Array2D<Int>, _ model: FinderModel2D = .Straight){
        self.config = conf;
        self.model = model;
    }
}
extension TestFinderDataSource: FinderDataSourceType{
    
    func neighborsOf(point: FinderPoint2D) -> [FinderPoint2D] {
        var neighbors: [FinderPoint2D] = [];
        let ns = model.neighborsOffset();
        ns.forEach{
            let op = $0;
            let x = op.0 + point.x;
            let y = op.1 + point.y;
            guard config.columns > x && x > -1 && y > -1 && config.rows > y else {return;}
            neighbors.append(FinderPoint2D(x: x, y: y));
        }
        return neighbors;
    }
    
    func getCost(point: FinderPoint2D) -> Int? {
        return self.config[point.x, point.y];
    }
}