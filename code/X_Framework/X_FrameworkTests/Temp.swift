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

    
//    let temp = TempSeq();
    let temp = TempCol()
    
    print(TempCol.Generator.Element.self, temp.count, temp.isEmpty)
    
    print(temp.maxElement());
    for n in temp
    {
        print(n);
    }
    
    
    print("tempTest================================end")
}
//
//
//struct A2dIndex: ForwardIndexType {
//    var index: A2dIndex.Distance;
//    init(index:A2dIndex.Distance)
//    {
//        self.index = index;
//    }
//    
//    func successor() -> A2dIndex {
//        return A2dIndex(index: index + 1)
//    }
//    
//    func distanceTo(end: A2dIndex) -> A2dIndex.Distance {
//        return end.index - self.index;
//    }
//    
//    func advancedBy(n: A2dIndex.Distance) -> A2dIndex {
//        return A2dIndex(index: index + n);
//    }
//    
//    func advancedBy(n: A2dIndex.Distance, limit: A2dIndex) -> A2dIndex {
//        let _i = index + n;
//        if _i >= limit.index{
//            return A2dIndex(index: 0);
//        }
//        return A2dIndex(index: _i);
//    }
//}
//func ==(lsh:A2dIndex, rsh:A2dIndex) -> Bool
//{
//    return true;
//}
//
//struct TempC<T>: CollectionType {
//    var source:[T] = [];
//    
//    typealias Generator = IndexingGenerator<[T]>
//    
//    func generate() -> Generator {
//        return self.source.generate()
//    }
//    
//    typealias Index = A2dIndex;
//    /// collection type
//    var startIndex: A2dIndex {return A2dIndex(index: 0)}
//    var endIndex: A2dIndex {return A2dIndex(index:self.source.count);}
//    subscript(i: A2dIndex) -> T {return self.source[i.index]}
//}
//
//struct TempCollection<T>: CollectionType {
//    var source:[T] = [];
//
////    //SequenceType
////    typealias Generator = AnyGenerator<T>;
////
////    func generate() -> Generator {
////        return anyGenerator(self.source.generate())
////    }
//    
//    /// collection type
//    var startIndex: Int {return 0}
//    var endIndex: Int {return self.source.count;}
//    subscript(i: Int) -> T {return self.source[i]}
//}


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




