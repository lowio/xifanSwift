//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;

private var isSingle: Bool = false;

//typealias PF = BreadthBestPathFinder<TestMap>
//typealias PF = DijkstraPathFinder<TestMap>
//typealias PF = GreedyBestPathFinder<TestMap>
//typealias PF = AstarPathFinder<TestMap>

func pathFinderTest(markVisited: Bool = true, markPath: Bool = true, isDiagnal: Bool = true) {
//    let finder = PF();
//    
//    let size = 35;
//    var conf = Array2D(columns: size, rows: size, repeatValue: 1);
//    conf[0,0] = 0;
//    
//    let h = PFinderHuristic2D.Euclidean;
//    let m: PFinderPassMode2D = isDiagnal ? .Diagonal : .Straight;
//    
//    let start = PFPosition2D(x: 17, y: 17);
//    let goals = [PFPosition2D(x: 7, y: 7), PFPosition2D(x: 7, y: 27), PFPosition2D(x: 27, y: 27), PFPosition2D(x: 27, y: 7)];
//    var map = TestMap(goals: goals, heristic: h, passMode: m, conf);
//    map.origin = start;
//    
//    var visited:[PF.Element]?;
//    var vsitation: (([PF.Element]) -> ())?
//    if markVisited{
//        vsitation = {visited = $0;}
//    }
//    var mp = Array2D(columns: size, rows: size, repeatValue: "✅");
//    
//    var path: [[PFPosition2D]] = [];
//    finder.execute(request: map, findPath: {
//        path.append($0);
//    }, vsitation);
//    
//    
//    guard markPath else {return;}
//    
//    
//    if let v = visited{
//        for e in v{
//            let p = e.position;
//            guard let pp = (e.parent as? PF.Element)?.position else{continue;}
//            let arrow = TestArrow.getArrow(p.x, y1: p.y, x2: pp.x, y2: pp.y).description;
//            mp[p.x, p.y] = arrow;
//        }
//    }
//    
//    for ps in path{
//        for p in ps{
//            let arrow = "📍";
//            mp[p.x, p.y] = arrow;
//        }
//    }
//    mp[start.x, start.y] = "🚹";
//    for g in goals{
//        mp[g.x , g.y] = "🚺";
//    }
//    print(mp);
//    
//    
//    //    jump point search
//    //    visited replace dictionary to index...
//    //    diagoanl
}


//struct TestMap{
//    let config: Array2D<Int>;
//    
//    let heuristic: PFinderHuristic2D;
//    
//    let passMode: PFinderPassMode2D;
//    
//    var goals: [PFPosition2D];
//    var goal: PFPosition2D;
//    var isComplete: Bool = false;
//    
//    var origin: PFPosition2D?;
//    
//    
//    init(goals: [PFPosition2D], heristic: PFinderHuristic2D, passMode: PFinderPassMode2D = .Straight, _ conf: Array2D<Int>){
//        self.config = conf;
//        self.goals = goals;
//        self.goal = goals[0];
//        self.heuristic = heristic;
//        self.passMode = passMode;
//    }
//}
//extension TestMap: PathFinderRequestType{
//    //return neighbors(passable) of position
//    func neighborsOf(position: PFPosition2D) -> [PFPosition2D]{
//        var arr: [PFPosition2D] = [];
//        let ns = passMode.neighborsOffset();
//        ns.forEach{
//            let op = $0;
//            let x = op.0 + position.x;
//            let y = op.1 + position.y;
//            guard config.columns > x && x > -1 && y > -1 && config.rows > y else {return;}
//            let cst = config [x, y];
//            guard cst > 0 else {return;}
//            arr.append(PFPosition2D(x: x, y: y));
//        }
//        return arr;
//    }
//    
//    //return cost between position and toPosition
//    func costOf(position: PFPosition2D, _ toPosition: PFPosition2D) -> CGFloat {
//        return CGFloat(config[toPosition.x, toPosition.y]);
//    }
//    
//    //return h value between position and toPosition
//    func heuristicOf(position: PFPosition2D) -> CGFloat {
//        let h = self.heuristic.heuristicOf(position, self.goal);
//        return h;
//    }
//    
//    mutating func findTarget(position: PFPosition2D) -> Bool {
//        if isSingle{
//            guard position == self.goal else{return false;}
//            self.isComplete = true;
//            return true;
//        }
//        else{
//            guard let i = self.goals.indexOf(position) else {return false;}
//            self.goals.removeAtIndex(i);
//            if self.goals.isEmpty{
//                self.isComplete = true;
//            }
//            return true;
//        }
//    }
//}