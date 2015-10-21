//
//  XArrayND.swift
//  X_Framework
//
//  Created by 173 on 15/9/16.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: collection 2d type
public protocol Collection2DType
{
    //collection type
    typealias _Collection: CollectionType;
    
    //source
    var source: _Collection{get}
    
    //columns
    var columns:Int{get}
    
    //rows
    var rows:Int{get}
    
    //cuont
    var count:_Collection.Index.Distance{get}
    
    //subscript
    subscript(column:Int, row:Int) -> _Collection.Generator.Element{get set}
    
    //column, row is valid
    func isValid(column:Int, _ row:Int) -> Bool
}
//MARK: extension public
extension Collection2DType
{
    //cuont
    public var count: _Collection.Index.Distance {return self.source.count}
    
    //column, row is valid
    public func isValid(column:Int, _ row:Int) -> Bool
    {
        return column >= 0 && column < columns && row >= 0 && row < rows;
    }
}
extension Collection2DType where Self._Collection.Generator.Element : Equatable
{
    public func indexOf(element:Self._Collection.Generator.Element) -> Self._Collection.Index?
    {
        return self.source.indexOf(element);
    }
}
//MARK: extension internal
extension Collection2DType
{
    //return index in array at column and row
    func indexAt(column:Int, _ row:Int) -> Int?
    {
        guard self.isValid(column, row) else {return nil;}
        return column + columns * row
    }
}

//MARK: struct array 2d
public struct Array2D<T>
{
    private(set) public var source: _Collection;
    private(set) public var columns, rows, count:Int;
    
    public init(columns:Int, rows:Int, values: _Collection? = nil)
    {
        self.columns = columns;
        self.rows = rows;
        self.count = columns * rows;
        guard let v = values else {
            self.source = _Collection(count: count, repeatedValue: nil);
            return;
        }
        var s = v
        if s.count < count
        {
            s += _Collection(count: count - s.count, repeatedValue: nil)
        }
        self.source = s;
    }
}

//MARK: extension Array2DType
extension Array2D: Collection2DType
{
    public typealias _Collection = Array<T?>;
    
    //subscript
    public subscript(column:Int, row:Int) -> _Collection.Generator.Element{
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

//MARK: extension CustomStringConvertible
extension Array2D: CustomDebugStringConvertible
{
    public var debugDescription:String{
        var text:String = "";
        for r in 0..<self.rows
        {
            for c in 0..<self.columns
            {
                if let v = self[c, r]
                {
                    text += "\(v) ";
                    continue;
                }
                text += "\(self[c, r]) ";
            }
            text += "\n";
        }
        return text;
    }
}
