//
//  Finder2DImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/10.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

///default 2d point struct
//MARK: == FinderPoint2D ==
public struct FinderPoint2D: FinderPoint2DType
{
    //x, y
    public let x: Int;
    public let y: Int;
    private var _hashValue: Int;
    
    public init(x: Int, y: Int)
    {
        self.x = x;
        self.y = y;
        self._hashValue = "\(x)\(y)".hashValue;
    }
    
    public var hashValue: Int{return self._hashValue;}
}
public func ==(lsh: FinderPoint2D, rsh: FinderPoint2D) -> Bool{return lsh.x == rsh.x && lsh.y == rsh.y;}

//MARK: == FinderHeuristic2D ==
public enum FinderHeuristic2D {
    case Manhattan, Euclidean, Octile, Chebyshev, None
}
extension FinderHeuristic2D {
    public func heuristicOf<T: FinderPoint2DType>(from f: T, to t: T) -> CGFloat {
        let dx = CGFloat(abs(f.x - t.x));
        let dy = CGFloat(abs(f.y - t.y));
        let h: CGFloat!;
        switch self{
        case .Manhattan:
            h = dx + dy;
        case .Euclidean:
            h = sqrt(dx * dx + dy * dy);
        case .Octile:
            let f:CGFloat = CGFloat(M_SQRT2) - 1;
            h = dx < dy ? f * dx + dy : f * dy + dx;
        case .Chebyshev:
            h = max(dx, dy);
        case .None:
            h = 0;
        }
        return h;
    }
}

//MARK: == FinderPoint2DType ==
public protocol FinderPoint2DType: Hashable{
    ///x
    var x: Int{get}
    
    ///y
    var y: Int{get}
    
    ///init
    init(x: Int, y: Int)
}

//MARK:  == FinderOption2DType ==
public protocol FinderOption2DType: FinderOptionType{
    ///point type
    typealias Point: FinderPoint2DType;
    
    ///heuristic
    var heuristic: FinderHeuristic2D{get}
    
    ///return calculate movement cost from f to t if it is validity(and exist)
    ///otherwise return nil
    func getCost(x: Int, y: Int) -> CGFloat?
}
extension FinderOption2DType {
    ///return calculate movement cost from f to t if it is validity(and exist)
    ///otherwise return nil
    public func calculateCost(from f: Point, to t: Point) -> CGFloat? {
        guard let cost = self.getCost(t.x, y: t.y) else {return .None;}
        guard self.model == .Diagonal else{return cost;}
        return cost * 1.4;
    }
    
    ///return neighbors of point
    public func neighborsOf(point: Point) -> [Point] {
        var neighbors: [Point] = [];
        let ns: [(Int, Int)]!
        switch self.model{
        case .Diagonal:
            ns = [(-1, 0), (0, 1), (1, 0), (0, -1), (-1, 1), (-1, -1), (1, -1), (1, 1)];
        case .Straight:
            ns =  [(-1, 0), (0, 1), (1, 0), (0, -1)];
        }
        ns.forEach{
            let op = $0;
            let x = op.0 + point.x;
            let y = op.1 + point.y;
            guard let _ = self.getCost(x, y: y) else {return;}
            neighbors.append(Point(x: x, y: y));
        }
        return neighbors;
    }
    
    ///return estimate h value from f point to t point
    public func estimateCost(from f: Point, to t: Point) -> CGFloat {
        return self.heuristic.heuristicOf(from: f, to: t);
    }
}






