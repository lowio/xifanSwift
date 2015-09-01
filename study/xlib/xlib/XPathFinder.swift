//
//  XPathFinder.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

struct XPathFinder {
    
}

extension XPathFinder:XPF
{
    func pathFinder(startNode sn:XPFNode, goalNode gn:XPFNode, map:XPFMap, completion:([XPFNode])->())
    {
        var currentNode = sn;
        var openHeap = XPriorityQueue<XPFNode>(){$0.0.f > $0.1.f}
//        currentNode.visited = true;
        openHeap.push(currentNode);
        while(!openHeap.empty)
        {
            currentNode = openHeap.pop()!;
            if(pathFinded(currentNode: currentNode, goalNode: gn)){break;}
            
            var neighbors = map.getNeighbors(atNode: currentNode);
            var neighbor = neighbors.pop();
            while(neighbor != nil)
            {
                if(neighbor!.closed){continue;}
                if(!neighbor!.visited)
                {
                    
                }
                else
                {
                    
                }
                neighbor = neighbors.pop();
            }
        }
        
        let path = rebuildPath(atNode: currentNode);
        completion(path);
    }
    
    //rebuild path
    private func rebuildPath(atNode n:XPFNode) -> [XPFNode]
    {
        var path = [XPFNode]();
        return path;
    }
    
    //current node is goal node?
    private func pathFinded(currentNode cn:XPFNode, goalNode gn:XPFNode) -> Bool
    {
        return false;
    }
}