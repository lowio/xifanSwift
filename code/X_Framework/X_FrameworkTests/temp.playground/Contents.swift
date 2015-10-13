//: Playground - noun: a place where people can play

import UIKit


protocol P
{
    func a()
}

extension P
{
    func a()
    {
        print("p a");
    }
    
    func b()
    {
        print("p b");
    }
    
    
}


struct S:P {
    func a() {
        print("s a");
    }
    
    func b()
    {
        print("s b");
    }
}

func test<T:P>(s:T)
{
    s.a();
    s.b();
}

test(S())

