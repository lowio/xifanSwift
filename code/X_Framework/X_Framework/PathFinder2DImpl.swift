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


