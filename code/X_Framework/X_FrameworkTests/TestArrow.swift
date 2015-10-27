//
//  TestArrow.swift
//  X_Framework
//
//  Created by 173 on 15/10/27.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


enum TestArrow
{
    case L, R, T, B, TL, TR, BL, BR
}
extension TestArrow:CustomStringConvertible
{
    var description:String{
        switch self{
        case .L:
            return "←";
        case .R:
            return "→";
        case .T:
            return "↑";
        case .B:
            return "↓";
        case .TL:
            return "↖";
        case .TR:
            return "↗";
        case .BL:
            return "↙";
        case .BR:
            return "↘";
        }
    }
}