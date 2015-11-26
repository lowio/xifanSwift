//
//  PathFinding.swift
//  X_Framework
//
//  Created by 173 on 15/11/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == PathFinderType ==
public protocol PathFindingType {
    
    //element Type
    typealias Element: PFElementType;
    
    //return element
    func elementOf(position: Self.Element.Position, parent: Self.Element, visited: Self.Element?) -> Self.Element?
}
extension PathFindingType {
    //decompress path
    func decompress<E: PFElementType>(element: E) -> [E.Position]
    {
        var path: [E.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? E else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}
extension PathFindingType {
    
    //execute
    func execute<Q: PFQueueType, S: PFSourceType where Q.Element == Self.Element, S.Position == Q.Element.Position>(origin: S.Position, queue: Q, source: S, @noescape findPath: ([S.Position]) -> ()) -> Q {
        
//        let originElement = Q.Element(g: 0, h: 0, position: origin, parent: nil);
//        var q = queue;
//        q.insert(originElement);
//        repeat{
//            guard let current = q.popBest() else {break;}
//            let position = current.position;
//            
//            if let flag = req.findGoal(position) {
//                let path = self.decompress(current);
//                findPath(path);
//                if flag {return q;}
//            }
//            
//            let neighbors = self.source.neighborsOf(position);
//            neighbors.forEach{
//                let p = $0;
//                let visited = queue[p];
//                guard let ele = self.elementOf(p, current, visited) else {return;}
//                visited == nil ? q.insert(ele) : q.update(ele);
//            }
//        }while true
//        return q;
    }
}
