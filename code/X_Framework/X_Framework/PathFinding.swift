//
//  PathFinding.swift
//  X_Framework
//
//  Created by 173 on 15/11/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

public protocol PathFindingType{
    
    //position type
    typealias Position: Hashable;
    
    //exploring
    @warn_unused_result
    func exploring<Element: PFElementType where Element.Position == Self.Position>(position: Self.Position, parent: Element, visited: Element?) -> Element?
}

//MARK: == PathFinderDelegate ==
public struct PathFinderDelegate<S: PFSourceType> {
    
    //origin
    public var origin: S.Position!;
    
    //source
    public var source: S!;
    
    
    
    
    //execute
    mutating public func execute<PF: PathFindingType, Q: PFQueueType where Q.Element.Position == PF.Position>(finder: PF) -> [[Q.Element.Position]]? {
//        guard let s = self.source else{return nil;}
//        var req = r;

        
        
//        
        var paths: [[Q.Element.Position]]?;
//        let originElement = Q.Element(g: 0, h: 0, position: request.origin, parent: nil);
//        queue.insert(originElement);
//        var req = request;
//        var paths: [[P]] = [];
//        repeat{
//            guard let current = queue.popBest() else {break;}
//            let position = current.position;
//            if let flag = req.findGoal(position) {
//                let path = self.decompress(current);
//                paths.append(path);
//                guard !flag else {return paths;}
//            }
//            let neighbors = source.neighborsOf(position);
//            neighbors.forEach{
//                let p = $0;
//                let visited = queue[p];
//                guard let ele = finder.exploring(p, parent: current, visited: visited, request: req, source: source) else {return;}
//                visited == nil ? queue.insert(ele) : queue.update(ele);
//            }
//        }while true
        return paths;
    }
    
    //decompress path
    func decompress<Element: PFElementType>(element: Element) -> [Element.Position]
    {
        var path: [Element.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}
//change PathFindingType to struct + delegate protocol