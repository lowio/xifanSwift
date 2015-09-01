//: Playground - noun: a place where people can play

import UIKit


class A
{
    var b = 0;
    
    func update(temp:Int)
    {
        b = temp;
    }
}

func c(a:A)
{
    a.update(20);
}

var d = A();
c(d);
d;