//
//  AboutCollection.swift
//  X_Framework
//
//  Created by xifanGame on 15/10/23.
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


//struct Address {
//    var streetAddress: String
//    var city: String
//    var state: String
//    var postalCode: String
//}
//
//var test1 = Address(streetAddress: "1 King Way", city: "Kings Landing", state: "Westeros", postalCode: "12345")
//var test2 = test1
//var test3 = test2
//
//struct AddressBits {
//    let underlyingPtr: UnsafeMutablePointer<Void>
//    let padding1: Int
//    let padding2: Int
//    let padding3: String
//    let padding4: String
//    let padding5: String
//}
//
//
//test2.streetAddress = "aaa";
//test3.streetAddress = "aaa";
//
//let bits1 = unsafeBitCast(test1, AddressBits.self)
//let bits2 = unsafeBitCast(test2, AddressBits.self)
//let bits3 = unsafeBitCast(test3, AddressBits.self)
//
//bits1.underlyingPtr
//bits2.underlyingPtr
//bits3.underlyingPtr


