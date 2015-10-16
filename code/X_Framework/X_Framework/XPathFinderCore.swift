//
//  XPathFinderCore.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/15.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=================== can be scanned tile protocol for XPathFinderType ===================
//MARK: XPathFinderTile
protocol XPathFinderTile
{
    //movement cost
    var movementCost:Int{get}
    
    //passable
    var passable:Bool{get}
    
    //parent
    var parent:XPathFinderTile?{get set}
    
    //convert to path chain array
    func toPathChain() -> [Self]
}
extension XPathFinderTile
{
    var movementCost:Int{return 1;}
    var passable:Bool{return self.movementCost > 0;}
    
    func toPathChain() -> [Self]
    {
        var chain:[Self] = [];
        var grid = self;
        repeat{
            chain.append(grid);
            guard let p = grid.parent as? Self else{break;}
            grid = p;
        }while true
        return chain;
    }
}

//================ path finder open list element type ================
//MARK: XPathFinderScannable
protocol XPathFinderScannable
{
    typealias _Tile:XPathFinderTile;
    
    //g score
    var g:Int{get set}
    
    //h score
    var h:Int{get set}
    
    //f score
    var f:Int{get}
    
    //tile
    var tile:Self._Tile?{get set}
    
    //is closed
    var closed:Bool{get set}
    
    //init
    init(g:Int, h:Int)
    
    //priority compare
    static func compare(p1:Self, p2:Self) -> Bool
}
extension XPathFinderScannable
{
    var f:Int{return self.h + self.g;}
    
    static func compare(p1:Self, p2:Self) -> Bool
    {
        return p1.f > p2.f;
    }
}

//========================= XPathFinderType ===========================
//MARK: XPathFinderType
protocol XPathFinderType
{
    typealias _Scannable: XPathFinderScannable;
    
    //grid is goal?
    func isTarget(element: Self._Scannable._Tile) -> Bool
    
    //start tile
    var start:Self._Scannable._Tile?{get}
    
    //goal tile
    var goal:Self._Scannable._Tile?{get}
    
    //return visited [_Scannable._Tile] used by findPath-visitedCallback
    var visitedTiles:[Self._Scannable._Tile]{get}
    
    //return h score used by f = h + g
    func heuristic(fromTile: Self._Scannable._Tile, _ toTile: Self._Scannable._Tile) -> Int
    
    //return neighbors [Self._Scannable._Tile]
    func getNeighbors(tile: Self._Scannable._Tile) -> [Self._Scannable._Tile]
    
    //return visited _Scannable by tile
    func getVisited(tile: Self._Scannable._Tile) -> Self._Scannable?
    
    //return closed _Scannable by tile
    func getClosed(tile: Self._Scannable._Tile) -> Self._Scannable?
    
    //no path, has dead end
    func deadEnd() -> Bool
    
    //reset pathFinder
    mutating func reset()
    
    //set _Scannable visited at tile
    mutating func setVisited(tile: Self._Scannable._Tile, scanner: Self._Scannable)
    
    //set _Scannable closed at tile
    mutating func setClosed(tile: Self._Scannable._Tile, scanner: Self._Scannable)
    
    //update scannable witch has a better g score
    mutating func updateScannable(scannable: Self._Scannable)
    
    //push it to scanning queue
    mutating func push(scannable: Self._Scannable)
    
    //pop a scannable at scanning queue
    mutating func pop() -> Self._Scannable
    
    //findPath main
    mutating func findPath(pathCallback:([Self._Scannable._Tile]) -> (), _ visitedCallback:([Self._Scannable._Tile] -> ())?)
}
private extension XPathFinderType
{
    //create scannable
    func _createScannable(g:Int, _ h:Int) -> Self._Scannable
    {
        return Self._Scannable.init(g:g, h:h);
    }
}
extension XPathFinderType
{
    mutating func findPath(pathCallback:([Self._Scannable._Tile]) -> (), _ visitedCallback:([Self._Scannable._Tile] -> ())? = nil)
    {
        guard let sg = self.start else{return;}
        guard let gg = self.goal else{return;}
        
        //reset pathFinder
        self.reset();
        
        //create start scannable
        let h = self.heuristic(sg, gg);
        var _scanning:Self._Scannable = self._createScannable(0, h);
        _scanning.tile = sg;
        
        //set start scannable
        self.setVisited(sg, scanner: _scanning);
        self.push(_scanning);
        
        //scan over
        defer{
            if let temp = _scanning.tile{
                pathCallback(temp.toPathChain());
            }
            
            if let _visitedCallback = visitedCallback{
                _visitedCallback(self.visitedTiles);
            }
        }
        
        //repeat cannable tile
        repeat{
            // get next scannable then set closed and update it visited
            _scanning = self.pop();
            guard let tile = _scanning.tile else{break;}
            guard !self.isTarget(tile) else{break;}
            _scanning.closed = true;
            self.setVisited(tile, scanner: _scanning);
            
            //scan current scannable's neighbors
            let neighbors = self.getNeighbors(tile);
            for n in neighbors
            {
                let g = _scanning.g + n.movementCost;
                guard let v = self.getVisited(n) else{
                    //not visited before, it is new scannable
                    var o:Self._Scannable = self._createScannable(g, self.heuristic(n, gg))
                    o.tile = n;
                    o.tile?.parent = tile;
                    self.setVisited(n, scanner: o);
                    self.push(o);
                    continue;
                }
                
                //current scannable is closed before ?
                guard !v.closed else{continue;}
                //not closed, check g, choose best g then update it's parent and g
                guard v.g > g else{continue;}
                var updateNode = v;
                updateNode.tile?.parent = tile;
                updateNode.g = g;
                self.setVisited(n, scanner: updateNode);
                print("注意前方高能：此处出现已经在访问列表中的g需要更新", __LINE__)
                self.updateScannable(v);
            }
        }while !self.deadEnd()
    }
}
//=========================================================================