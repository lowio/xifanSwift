//
//  AboutCollection.swift
//  X_Framework
//
//  Created by 173 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


struct TempTypealias {
    typealias AT = Array<Int>;
    typealias DT = Dictionary<Int, Int>;
    typealias DTI = DictionaryIndex<Int, Int>;
    typealias FIT = AnyForwardIndex;
    typealias ST = Set<Int>;
}


func tempTest(active:Bool = false)
{
    if !active{return;}
    print("tempTest================================start")

    
    let temp = TempSeq();
//    let temp = TempCol()
    
    print(TempCol.SubSequence.self)
    
    print(temp.maxElement());
    for n in temp
    {
        print(n);
    }
    
    print("tempTest================================end")
}

public struct TempSeq: SequenceType {
    public typealias Generator = IndexingGenerator<Array<Int>>;
    
    public func generate() -> Generator {
        print("hehe")
        return Generator([0, 1, 2, 3]);
    }
}

public struct TempCol: CollectionType
{
    public var startIndex: Int {return 0}
    public var endIndex: Int {return 10;}
    public subscript(i: Int) -> String {return "a"}
}





