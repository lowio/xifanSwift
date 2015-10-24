//
//  OptimumFinder2DImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: finder point 2d
protocol FinderPoint2D
{
    //x position
    var x:Int{get}
    
    //y position
    var y:Int{get}
}

//MARK: finder huristic 2d
enum FinderHuristic2D<T: FinderPoint2D>
{
    case Manhattan, Euclidean, Octile, Chebyshev
}
extension FinderHuristic2D: FinderHeuristic
{
    
    typealias _Point = T;
    
    func getHeuristic(from: _Point, toPoint: _Point) -> Int {
        let dx = abs(from.x - toPoint.x);
        let dy = abs(from.y - toPoint.y);
        switch self{
        case .Manhattan:
            return dx + dy;
        case .Euclidean:
            return Int(sqrt(CGFloat(dx * dx + dy * dy)));
        case .Octile:
            let f:CGFloat = sqrt(2.0) - 1;
            let _dx = CGFloat(dx);
            let _dy = CGFloat(dy);
            return Int(_dx < _dy ? f * _dx + _dy : f * _dy + _dx);
        case .Chebyshev:
            return max(dx, dy);
        }
    }
}
