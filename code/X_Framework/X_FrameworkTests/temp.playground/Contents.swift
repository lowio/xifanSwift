//: Playground - noun: a place where people can play

import SpriteKit
import UIKit
import X_Framework


enum E
{
    case A(Int)
    case B(Int)
}

let e = E.A(10);

func test()
{
    guard case let .A(b) = e else{return;}
    print(b);
}

test();