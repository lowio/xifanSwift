//: Playground - noun: a place where people can play

import UIKit

protocol P{
    func a();
}

extension P
{
    func a()
    {
        print("a");
    }
    
    func b()
    {
        a();
    }
}

struct S:P {
    func a()
    {
        print("a2222");
    }
}

var sp = S();
sp.b();