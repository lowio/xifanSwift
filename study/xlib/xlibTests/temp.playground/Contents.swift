//: Playground - noun: a place where people can play

import UIKit


struct A:Printable
{
    var b = 0;
    
    var description:String{
        return "a";
    }
}

let c = String(stringInterpolationSegment: A());