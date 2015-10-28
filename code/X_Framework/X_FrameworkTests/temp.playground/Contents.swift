//: Playground - noun: a place where people can play

import SpriteKit
import UIKit
import X_Framework

struct Indexs: Indexable {
    var startIndex: Int{return 10;}
    var endIndex:Int{return 0;}
    subscript(i:Int) -> Int{
        return i;
    }
}