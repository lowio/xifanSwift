//
//  PathFinder.swift
//  X_Framework
//
//  Created by 173 on 15/11/6.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PathChainable ==
public protocol PathChainable
{
    //parent
    var parent: PathChainable?{get}
}

//MARK: == PathComparable ==
public protocol PathComparable: PathChainable
{
    //point type
    typealias Point: Hashable;
    
    //'self' is closed default false
    var isClosed:Bool{get set}
    
    //g score, real cost from start point to 'self' point
    var g: CGFloat{get}
    
    //h score, hurisctic cost from 'self' point to goal point
    var h: CGFloat{get}
    
    //weight f = g + h
    var f:CGFloat{get}
    
    //point
    var point: Self.Point{get}
    
    //set parent
    mutating func setParent(parent: FinderChainable, g: CGFloat)
    
    //init
    init(g: CGFloat, h:CGFloat, point: Self.Point, parent: FinderChainable?)
}

//MARK: == PathFinderType ==
public protocol PathFinderType
{
    
}







