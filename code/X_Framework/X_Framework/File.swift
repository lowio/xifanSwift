//
//  File.swift
//  X_Framework
//
//  Created by 173 on 15/11/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == PathFinderType ==
public protocol PFP {
    //request type
    typealias Request: PathFinderRequestType;
    
    //queue type
    typealias Queue: PathFinderQueueType;
    
    //position type
    typealias Position: Hashable = Self.Queue.Element.Position;
    
    //create queue
    func queueGenerate() -> Self.Queue;
    
    //explore return nil do nothing else return.1 = true do insert return.1 = false do update
    func explore(request: Self.Request, _ position: Self.Position, _ parent: Self.Queue.Element?, _ visited: Self.Queue.Element?) -> (Self.Queue.Element, Bool)?
    
    //execute
    func execute(request req: Self.Request, findPath:([Self.Position]) -> (), _ completion: (([Self.Queue.Element]) -> ())?)
}
extension PFP where Self.Request.Position == Self.Position, Self.Queue.Element.Position == Self.Position {
    
    //element type
    typealias Element = Self.Queue.Element;
    
    //decompress path
    func decompress(element: Element) -> [Self.Position]
    {
        var path: [Self.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
    
    //execute
    public func execute(request req: Self.Request, findPath: ([Self.Position]) -> (), _ completion: (([Self.Queue.Element]) -> ())? = nil) {
        guard let origin = req.origin else {return;}
        var request = req;
        var queue = self.queueGenerate();
        self.explore(req, origin, nil, nil);
        repeat{
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            
            if request.findTarget(position) {
                let path = self.decompress(current);
                findPath(path);
                if request.isComplete {
                    completion?(queue.allVisitedList());
                    break;
                }
            }
            
            let neighbors = request.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                guard let ele = self.explore(req, p, current, queue[p]) else {return;}
                let isNew = ele.1;
                let e = ele.0;
                isNew ? queue.insert(e) : queue.update(e);
            }
        }while true
    }
}