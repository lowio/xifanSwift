//
//  XPathFind2DImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/16.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=========================================================================
//MARK: XPathFinderTile2D
protocol XPathFinderTile2D:XPathFinderCostTile
{
    var x:Int{get}
    var y:Int{get}
    
    init(_ x:Int, _ y:Int)
}

//MARK: XPFinderTile2D
struct XPFinderTile2D {
    private(set) var x, y:Int;
    var passable:Bool{
        return movementCost > 0;
    }
    var parent:XPathFinderTile? = nil;
    var movementCost:Int = 1;
    
    init(_ x:Int, _ y:Int)
    {
        self.x = x;
        self.y = y;
        self.hashValue = "\(x),\(y)".hashValue;
    }
    
    private(set)var hashValue:Int;
}
extension XPFinderTile2D: XPathFinderTile2D{}
extension XPFinderTile2D: Hashable{}
func ==(lsh:XPFinderTile2D, rsh:XPFinderTile2D) -> Bool
{
    return lsh.x == rsh.x && lsh.y == rsh.y;
}

//=========================================================================
//MARK: XPFPriority
struct XPFScannable
{
    var g, h:Int;
    var tile:_Tile? = nil;
    var closed:Bool = false;
    
    private var _flag:Int;
    private var _f:Int;
    
    //计数器
    private static var _FLAG:Int = 0;
}
extension XPFScannable: XPathFinderScannable
{
    typealias _Tile = XPFinderTile2D;
    
    var f:Int{return self._f;}
    
    init(g: Int, h: Int) {
        self.g = g;
        self.h = h;
        self._f = self.g + self.h;
        self._flag = XPFScannable._FLAG++;
    }
    
    static func compare(p1:XPFScannable, p2:XPFScannable) -> Bool
    {
        let bl = p1.f > p2.f;
//        return bl;
        return bl ?? (p1._flag > p2._flag);
    }
}
extension XPFScannable: Equatable{}
func ==(lsh:XPFScannable, rsh:XPFScannable) -> Bool
{
    return lsh.f == rsh.f && lsh.tile == rsh.tile;
}

//=========================================================================
//MARK: XPFinder2D
struct XPFinder2D<T:XPathFinderScannable where T._Tile:XPathFinderTile2D, T._Tile:Hashable>
{
    typealias _Scannable = T;
    
    var start, goal:T._Tile?;
    
    private var algorithm:XPFAlgorithm2D;
    
    //config
    private(set) var config:Array2D<T._Tile?>;
    
    init(config:Array2D<T._Tile?>, algorithm:XPFAlgorithm2D)
    {
        self.config = config;
        self.algorithm = algorithm;
        
        self.openedQueue = PriorityArray<T>(isOrderedBefore: T.compare);
        self.visitedDic = [:];
    }
        
    //opened list
    private var openedQueue:PriorityArray<T>;
    
    //visited dictionay
    private var visitedDic:[T._Tile: T];
    
    //get tile
    func getTile(x:Int, _ y:Int) -> T._Tile?
    {
        guard let element = config[x, y] else{return nil;}
        return element.passable ? element : nil;
    }
}
extension XPFinder2D: XPathFinderType
{
    func heuristic(fromTile: T._Tile, _ toTile: T._Tile) -> Int
    {
        return algorithm.heuristic(fromTile.x, fromTile.y, toTile.x, toTile.y);
    }
    
    func getMovementCost(fromTile: T._Tile, _ toTile: T._Tile) -> Int
    {
        return toTile.movementCost;
    }
    
    func getNeighbors(tile: T._Tile) -> [T._Tile]
    {
        var neighbors:[T._Tile] = [];
        let pos = algorithm.neighbors(tile.x, tile.y);
        for p in pos
        {
            let x = p.0;
            let y = p.1;
            guard let t = getTile(x, y) else{continue;}
            neighbors.append(t);
        }
        return neighbors;
    }
    
    func isTarget(tile: T._Tile) -> Bool
    {
        return tile == self.goal
    }
    
    //get visited tiles for visitedCallback
    var visitedTiles:[_Scannable._Tile]{
        return Array(visitedDic.keys);
    }
    
    //continue scan
    func deadEnd() -> Bool
    {
        return openedQueue.isEmpty;
    }
    
    //push
    mutating func push(scannable: _Scannable)
    {
        self.openedQueue.append(scannable);
    }
    
    //pop
    mutating func pop() -> _Scannable
    {
        return self.openedQueue.popFirst()!;
    }
    
    //reset
    mutating func reset()
    {
        self.openedQueue = PriorityArray<_Scannable>(isOrderedBefore: _Scannable.compare);
        self.visitedDic = [:];
    }
    
    //get visited
    func getVisited(tile: _Scannable._Tile) -> _Scannable?
    {
        return self.visitedDic[tile];
    }
    
    //set visited
    mutating func setVisited(tile: _Scannable._Tile, scanner: _Scannable)
    {
        self.visitedDic[tile] = scanner;
    }
    
    //get closed
    func getClosed(tile: _Scannable._Tile) -> _Scannable?
    {
        guard let temp = self.visitedDic[tile] where temp.closed else{return nil;}
        return temp;
    }
    
    //set closed
    mutating func setClosed(tile: _Scannable._Tile, scanner: _Scannable)
    {
        self.setVisited(tile, scanner: scanner);
    }
    
    //update visited
    mutating func updateScannable(scannable: _Scannable)
    {
//        guard let index = try (self.openedQueue.indexOf{return scannable.f == $0.f && scannable.tile == $0.title})else{return;}
//        self.openedQueue.updateElement(scannable, atIndex: index);
//        print("注意前方高能：此处出现已经在访问列表中的g需要更新", scannable)
    }
}
extension XPFinder2D where T:Equatable
{
    mutating func updateScannable(scannable: _Scannable)
    {
        guard let index = self.openedQueue.indexOf(scannable) else{return;}
        self.openedQueue.updateElement(scannable, atIndex: index);
        print("注意前方高能：此处出现已经在访问列表中的g需要更新", scannable)
    }
}

//=========================================================================
//MARK XPFAlgorithm2D
enum XPFAlgorithm2D
{
    case Manhattan, Diagonal
    
    //heuristic
    func heuristic(fx:Int, _ fy:Int, _ tx:Int, _ ty:Int) -> Int
    {
        switch self{
        case .Manhattan:
            let x = abs(fx - tx);
            let y = abs(fy - ty);
            return x + y;
        case .Diagonal:
            let x = abs(fx - tx);
            let y = abs(fy - ty);
            return max(x, y);
        }
    }
    
    //neighbors
    func neighbors(x:Int, _ y:Int) -> [(Int, Int)]
    {
        switch self{
        case .Manhattan:
            return [(x-1, y), (x, y+1), (x+1, y), (x, y-1)];
        case .Diagonal:
            return [(x-1, y-1), (x-1, y), (x-1, y+1), (x, y+1),(x+1, y+1),  (x+1, y), (x+1, y-1), (x, y-1)];
        }
    }
}