//
//  XPathFinder.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: XPF_GridPrioriy
struct XPF_GridPrioriy: XPFGridPrioriyProtocol {
    var g:CGFloat;
    var h:CGFloat;
    var f:CGFloat{return g + h;}
    var isClosed:Bool = false;
}

//MARK: XPF_Grid
struct XPF_Grid: XPFGridProtocol, Hashable {
    var x:Int;
    var y:Int;
    var p:XPFGridProtocol?;
    
    var hashValue:Int{ return x^y; }
}

func ==(lsh:XPF_Grid, rsh:XPF_Grid) -> Bool
{
    return lsh.x == rsh.x && lsh.y == rsh.y;
}

//MARK: XPF_Map
struct XPF_Map<T:XPFGridProtocol>: XPFMapProtocol
{
    typealias G = T;
    
    func getHeuristicCost(fromGrid fg:G, toGrid tg:G) -> CGFloat{return 0;}
    
    func getMovementCost(fromGrid fg:G, toGrid tg:G) -> CGFloat{return 1;}
    
    func getNeighbors(atGrid: G) -> [G]{return [];}
}

//MARK: XPathFinder
struct XPathFinder {
    
}


//MARK: XPathFinder extension XPFProtocol
extension XPathFinder: XPFProtocol
{
    func pathFinder<M: XPFMapProtocol where M.G: Hashable>
        (startGrid sg: M.G, goalGride gg: M.G, map: M, completion: ([M.G]) -> ())
    {
        
        var openQueue = XPriorityQueue<M.G>{return $0.0.x > $0.1.x};
        
        
        
        
        while let grid = openQueue.pop()
        {
            if grid == gg
            {
                let path = rebuildPath(grid);
                completion(path);
                break;
            }
            
            let neighbors = map.getNeighbors(grid);
            
        }
    }
}

//MARK: XPathFinder extension private method
private extension XPathFinder
{
    //rebuild path
    private func rebuildPath<G:XPFGridProtocol>(grid:G) -> [G]
    {
        var path = [G]();
        return path;
    }
}