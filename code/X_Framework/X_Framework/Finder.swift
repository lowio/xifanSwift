//
//  Finder.swift
//  X_Framework
//
//  Created by 173 on 15/12/2.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElementType ==
public protocol FinderElementType {
    //point type
    typealias Point: Hashable;
    
    //point
    var point: Point {get}
    
    //is closed
    var isClosed: Bool{get set}
}

//MARK: == FinderSourceType ==
public protocol FinderSourceType {
    
    //point type
    typealias Point: Hashable;
    
    //return neighbors of point
    func neighborsOf(point: Point) -> [Point];
    
    ///return cost from f point to t point if it validate
    ///otherwise return nil
    func getCost(from f: Point, to t: Point) -> CGFloat?
}

//MARK: == FinderBufferType ==
public protocol FinderBufferType {
    /// finder element type
    typealias Element: FinderElementType;
    
    ///insert element
    mutating func insert(element: Element)
    
    ///return best element if not empty
    mutating func popBest() -> Element?
    
    ///update element
    mutating func update(element: Element)
    
    ///close element
    mutating func close(element: Element)
    
    ///return element if point is visited
    ///otherwise return nil
    subscript(point: Element.Point) -> Element? {get}
    
    ///return path
    func backtrace(element: Element) -> [Element.Point]
    
    ///trace visited record
    func backtraceRecord() -> [Element]
}

//MARK: == FinderDelegateType ==
public protocol FinderType {
    ///element type
    typealias Element: FinderElementType;
    
    ///explore point
    ///return element at point
    func explorePoint(point: Element.Point, cost: CGFloat, parent: Element?) -> Element
    
    ///explore visited element
    ///return element if need update
    ///otherwise return nil
    func exploreVisited(element: Element, parent: Element, cost: CGFloat) -> Element?
    
    ///find
    mutating func find<Source: FinderSourceType where Source.Point == Element.Point>
        (form point: Element.Point, to goal: Element.Point, source: Source) -> [Element.Point]
    ///find
    mutating func find<Source: FinderSourceType where Source.Point == Element.Point>
        (form point: Element.Point, to goals: [Element.Point], source: Source) -> [[Element.Point]]
}
extension FinderType {
    ///execute
    public func execute<
        S: FinderSourceType, B: FinderBufferType
        where B.Element == Element, S.Point == Element.Point
        >(var buffer: B, source: S, origin: Element.Point, @noescape _ isTerminal: (Element) -> Bool) -> B {
            let ele = self.explorePoint(origin, cost: 0, parent: nil);
            buffer.insert(ele);
            repeat{
                guard var element = buffer.popBest() where !isTerminal(element) else{break;}
                element.isClosed = true;
                buffer.close(element);
                let point = element.point;
                let neighbors = source.neighborsOf(point);
                neighbors.forEach{
                    let p = $0;
                    guard let cost = source.getCost(from: point, to: p) else {return;}
                    guard let visited = buffer[p] else{
                        let e = self.explorePoint(p, cost: cost, parent: element);
                        buffer.insert(e);
                        return;
                    }
                    guard !visited.isClosed else {return;}
                    guard let e = self.exploreVisited(visited, parent: element, cost: cost)else {return;}
                    buffer.update(e);
                }
            }while true
            return buffer;
    }
}





