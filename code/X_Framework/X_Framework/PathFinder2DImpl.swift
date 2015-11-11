//
//  PathFinder2DImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/10.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PFinderPosition2D ==
public struct PFinderPosition2D: Hashable
{
    //x, y
    var x, y: Int;
    
    init(x: Int, y: Int)
    {
        self.x = x;
        self.y = y;
    }
    
    public var hashValue: Int{return self.x ^ self.y;}
}
public func ==(lsh: PFinderPosition2D, rsh: PFinderPosition2D) -> Bool{return lsh.x == rsh.x && lsh.y == rsh.y;}


//MARK: == PFinderHuristic2D ==
public enum PFinderHuristic2D {
    case Manhattan, Euclidean, Octile, Chebyshev, None
}
extension PFinderHuristic2D {
    public func heuristicOf(position: PFinderPosition2D, _ toPosition: PFinderPosition2D) -> CGFloat {
        let dx = CGFloat(abs(position.x - toPosition.x));
        let dy = CGFloat(abs(position.y - toPosition.y));
        switch self{
        case .Manhattan:
            return dx + dy;
        case .Euclidean:
            return sqrt(dx * dx + dy * dy);
        case .Octile:
            let f:CGFloat = CGFloat(M_SQRT2) - 1;
            return dx < dy ? f * dx + dy : f * dy + dx;
        case .Chebyshev:
            return max(dx, dy);
        case .None:
            return 0;
        }
    }
}

//MARK: == PFinderPassMode2D ==
public enum PFinderPassMode2D{
    case Straight, Diagonal
}
extension PFinderPassMode2D{
    
    //return neighbors
    public func neighborsOffset() -> [(Int, Int)]{
        switch self{
        case .Straight:
            return [(-1, 0), (0, 1), (1, 0), (0, -1)];
        case .Diagonal:
            return [(-1, -1), (-1, 0), (-1, 1), (0, 1),(1, 1),  (1, 0), (1, -1), (0, -1)];
        }
    }
}


