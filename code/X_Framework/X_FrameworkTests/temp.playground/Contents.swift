//: Playground - noun: a place where people can play

import SpriteKit
import UIKit
import X_Framework


func test()
{
    var i = 0;
    repeat{
        i++;
        var j = 0;
        repeat{
            j++
            guard j > 3 else{break;}
        }while true
        print(i, j)
    }while i < 10;
}

test();