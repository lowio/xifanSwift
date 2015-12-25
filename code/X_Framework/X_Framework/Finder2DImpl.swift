//
//  Finder2DImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/10.
//  Copyright © 2015年 yeah. All rights reserved.
//

//import Foundation

//MARK: == FinderPoint2D ==
public struct FinderPoint2D: Hashable
{
    //x, y
    var x, y: Int;
    private var _hashValue: Int;
    
    init(x: Int, y: Int)
    {
        self.x = x;
        self.y = y;
        self._hashValue = "\(x)\(y)".hashValue;
    }
    
    public var hashValue: Int{return self._hashValue;}
}
public func ==(lsh: FinderPoint2D, rsh: FinderPoint2D) -> Bool{return lsh.x == rsh.x && lsh.y == rsh.y;}


//MARK: == FinderHeuristic2D ==
public enum FinderHeuristic2D: FinderHeuristicType {
    case Manhattan, Euclidean, Octile, Chebyshev, None
}
extension FinderHeuristic2D {
    public func heuristicOf(from f: FinderPoint2D, to t: FinderPoint2D) -> CGFloat {
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

//MARK: == FinderModel2D ==
public enum FinderModel2D{
    case Straight, Diagonal
}
extension FinderModel2D{
    
    //return neighbors
    public func neighborsOffset() -> [(Int, Int)]{
        switch self{
        case .Straight:
            return [(-1, 0), (0, 1), (1, 0), (0, -1)];
        case .Diagonal:
            return [(-1, 0), (0, 1), (1, 0), (0, -1), (-1, 1), (-1, -1), (1, -1), (1, 1)];
        }
    }
}





