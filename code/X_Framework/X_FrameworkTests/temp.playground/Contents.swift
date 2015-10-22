//: Playground - noun: a place where people can play

import SpriteKit
import UIKit
import X_Framework

typealias AAA = Array<Int>;
typealias DDD = Dictionary<Int, Int>
typealias FFF = DictionaryIndex<Int, Int>;


struct S<T>{
    
    var source:[T] = [];
    
//    typealias Generator = AnyGenerator<T>;
//    
//    func generate() -> Generator {
//        return anyGenerator(self.source.generate())
//    }
    
    /// The position of the first element in the collection. (Always zero.)
    var startIndex: Int {
        return 0
    }
    
    /// One greater than the position of the last element in the collection. Zero when the collection is empty.
    var endIndex: Int {
        return self.source.count;
    }
    
    /// Accesses the element at index `i`.
    ///
    /// Read-only to ensure sorting - use `insert` to add new elements.
    subscript(i: Int) -> T {
        return self.source[i]
    }
}
extension S: CollectionType
{
    
}



var s = S<String>();
s.source = ["a", "b", "e", "d", "c"];

s.count

s.indexOf("b");

