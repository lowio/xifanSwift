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
}

//MARK:  == FinderOption2DType ==
public protocol FinderOption2DType: FinderOptionType{
    typealias Point: FinderPoint2DType;
}
extension FinderOption2DType {
    ///return neighbors offset
    internal func neighborsOffset() -> [(Int, Int)]{
        switch self.model{
        case .Diagonal:
            return [(-1, 0), (0, 1), (1, 0), (0, -1), (-1, 1), (-1, -1), (1, -1), (1, 1)];
        case .Straight:
            return [(-1, 0), (0, 1), (1, 0), (0, -1)];
        }
    }
}





