//
//  XPathfinderType.swift
//  X_Framework
//
//  Created by 173 on 15/10/13.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit


protocol XPathGrid
{
    //x
    var x:Int{get set}
    
    //y
    var y:Int{get set}
    
    //parent
    var p:Self?{get set}
}

protocol XPathNode
{
    typealias XPriorityType:Comparable;
    
    //g score
    var g:CGFloat{get set}
    
    //h score
    var h:CGFloat{get set}
    
    //parent
    var p:Self?{get set}
    
    //is closed
    var closed:Bool{get set}
    
    //f score
    var f:CGFloat{get}
    
    //priority
    var priority:CGFloat{get}
    
    
}

extension XPathNode
{
    var f:CGFloat{return self.g + self.h;}
    var priority:CGFloat{return self.f;}
}


protocol XPathFinderType
{
    //XPathNode
//    typealias _XPathNode:XPathNode;
    
    
    
}

extension XPathFinderType
{
    
    private func _buildPath<N:XPathNode>(node:N) -> [N]
    {
        return [];
    }
    
    //path find
    func pathFind<N:XPathNode where N:Hashable, N:Equatable>(start:N, goal:N,
        heuristic:(N, N)->CGFloat, movementCost:(N, N)->CGFloat, getNeighbors:(N)->[N],
        completion:([N])->())
    {
        var visited = [N:N]();
        visited[start] = start;
        var openQueue = XPriorityQueue<N>{return $0.priority > $1.priority;}
        openQueue.push(start);
        
        var current:N;
        defer{
            let p = self._buildPath(current);
            completion(p);
        }
        
        repeat{
            current = openQueue.pop()!;
            guard current != goal else{break;}  //do defer
            
            current.closed = true;
            visited[current] = current;
            
            let neighbors = getNeighbors(current);
            for n in neighbors
            {
                let g = current.g + movementCost(current, n);
                guard let v = visited[n] else{
                    var o = n;
                    o.g = g;
                    o.h = heuristic(n, goal);
                    o.p = current;
                    o.closed = false;
                    visited[o] = o;
                    openQueue.push(o);
                    continue;
                }
        
                guard !v.closed && v.g > g else{continue;}
                var updateNode = v;
                updateNode.g = g;
                visited[updateNode] = updateNode;
                guard let index = openQueue.indexOf(v) else{continue;}
                openQueue.update(updateNode, atIndex: index);
            }
        }while !openQueue.isEmpty
    }
}