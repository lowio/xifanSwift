//
//  File.swift
//  X_Framework
//
//  Created by 173 on 15/11/20.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


public protocol PFinderRequest {
    
    //position type
    typealias Position: Hashable;
    
    //origin position
    var origin: Self.Position?{get}
    
    //is complete
    var isComplete: Bool{get}
    
    //postion is target?
    mutating func findTarget(position: Self.Position) -> Bool
}


public struct PFinderDelegate {
    
    //decompress path
    public func decompress<E: PFinderElementType>(element: E) -> [E.Position]
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
    
    //execute
//    public func execute(request req: Self.Request, findPath: ([Self.Position]) -> ()) {
//        guard let origin = req.origin else {return;}
//        var request = req;
//        var queue = self.queueGenerate();
//        self.searchPosition(origin, nil, request, &queue);
//        repeat{
//            guard let current = queue.popBest() else {break;}
//            let position = current.position;
//            
//            if request.findTarget(position) {
//                let path = self.decompress(current);
//                findPath(path);
//                if request.isComplete {
//                    completion?(queue.allVisitedList());
//                    return;
//                }
//            }
//            
//            let neighbors = request.neighborsOf(position);
//            neighbors.forEach{
//                self.searchPosition($0, current, request, &queue);
//            }
//        }while true
//    }

}