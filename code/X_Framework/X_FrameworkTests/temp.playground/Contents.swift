//: Playground - noun: a place where people can play

import UIKit





func a(b:Bool)
{
    defer{
        print("test1")
    }
    print("test2");
    
    if b{
        
        return;
    }
    print("test3");
    
    
    
}

a(false);