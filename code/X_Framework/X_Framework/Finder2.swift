//
//  Finder2.swift
//  X_Framework
//
//  Created by 173 on 15/12/29.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderDelegateType2 ==
protocol FinderDelegateType2: GeneratorType{
    ///point type
    typealias Point: Hashable;
    
    ///element type
    typealias Element = FinderElement<Point>;
    
    ///return next element
    /// - Requires: set element closed
    mutating func next() -> Element?
    
    ///insert element
    /// - Requires: set element visited
    mutating func insert(element: Element)
    
    ///update element
    mutating func update(element: Element)
    
    ///get the visited element and return it, or nil if no visited element exists at point.
    subscript(point: Point) -> Element? {get}
    
    ///return visited record
    func backtraceRecord() -> [Element]
    
    
    
    
    ///is terminal
    var isTerminal: Bool{get}
    
    ///exploring
    ///Return if the element'point is target
    /// - Parameters:
    ///     - element: current explored element
    mutating func exploring(element: Element) -> Bool
}
extension FinderDelegateType2 where Self.Element == FinderElement<Point>{
    ///back trace points
    func backtrace(element: Element) -> [Point]{
        let point = element.point;
        var result: [Point] = [point]
        var e = element;
        repeat{
            guard let backward = e.backward else{break;}
            result.append(backward);
            guard let be = self[backward] else {break;}
            e = be;
        }while true;
        return result;
    }
    
    ///Returns finding result start at element
    /// - Parameters:
    ///     - startAt: start element
    @warn_unused_result
    mutating func find(startAt e: Element) -> [Point: [Point]] {
        var result: [Point: [Point]] = [:];
        self.insert(e)
        repeat{
            guard let element = self.next() else{break;}
            if self.exploring(element) {
                result[element.point] = self.backtrace(element);
            }
        }while !self.isTerminal
        return result;
    }
}
