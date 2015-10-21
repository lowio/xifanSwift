//
//  Collection2D.swfit
//  X_Framework
//
//  Created by 173 on 15/9/16.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: collection 2d type
public protocol Collection2DType
{
    //element type
    typealias _Element
    
    //columns
    var columns: Int{get}
    
    //rows
    var rows: Int{get}
    
    //cuont
    var count: Int{get}
    
    //subscript
    subscript(column:Int, row:Int) -> _Element? {get set}
    
    //column, row is valid
    func isValid(column:Int, _ row:Int) -> Bool
}
//MARK: extension public
public extension Collection2DType
{
    //column, row is valid
    func isValid(column:Int, _ row:Int) -> Bool
    {
        return column >= 0 && column < columns && row >= 0 && row < rows;
    }
}
//MARK: extension internal
extension Collection2DType
{
    //return index in collection at column and row
    func indexAt(column:Int, _ row:Int) -> Int?
    {
        guard self.isValid(column, row) else {return nil;}
        return column + columns * row
    }
    
    //return position in collection, index: [0, count)
    func positionAt(index: Int) -> (column:Int, row:Int)?
    {
        guard index > -1 && index < self.count else{return nil;}
        let column = index % self.columns;
        let row:Int = index / self.columns;
        return (column: column, row: row);
    }
}
//MARK: extension CustomStringConvertible
public extension Collection2DType where Self: CustomDebugStringConvertible
{
    var debugDescription:String{
        var text:String = "";
        for r in 0..<self.rows
        {
            for c in 0..<self.columns
            {
                guard let ele = self[c, r] else{
                    text += "nil ";
                    continue;
                }
                text += "\(ele) ";
            }
            text += "\n";
        }
        return text;
    }
}

//MARK: struct array 2d
public struct Array2D<T>
{
    //source
    private var source: [T?];
    private(set) public var columns, rows, count:Int;
    
    public init(columns:Int, rows:Int, values: [T?]? = nil)
    {
        self.columns = columns;
        self.rows = rows;
        self.count = columns * rows;
        guard let v = values else {
            self.source = [T?](count: count, repeatedValue: nil);
            return;
        }
        var s = v
        if s.count < count
        {
            s += [T?](count: count - s.count, repeatedValue: nil)
        }
        self.source = s;
    }
    
    //to array
    public func toArray() -> [T?]{ return self.source; }
}

//MARK: extension Array2DType
extension Array2D: Collection2DType
{
    public typealias _Element = T;
    
    //subscript
    public subscript(column:Int, row:Int) -> _Element?{
        set{
            guard let index = self.indexAt(column, row) else{return;}
            self.source[index] = newValue;
        }
        get{
            guard let index = self.indexAt(column, row) else{return nil;}
            return self.source[index];
        }
    }
}
//MARK: extension contains and positionOf
extension Array2D where T: Equatable
{
    //contains element
    public func contains(element: T) -> Bool
    {
        guard let _ = positionOf(element) else {return false;}
        return true;
    }
    
    //if exist, return position else return nil
    public func positionOf(element: T) -> (column:Int, row:Int)?
    {
        guard let index = (self.source.indexOf{
            guard let ele = $0 else {return false;}
            return ele == element;
        }) else {return nil;}
        return positionAt(index);
    }
}
extension Array2D: CustomDebugStringConvertible{}