//
//  SquareGroup.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/30.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//方块
class SquareForm: NodeForm {
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(0, 0), (1, 0), (0, 1), (1, 1)],
            NodeOrientation.Nighty:[(0, 0), (1, 0), (0, 1), (1, 1)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (0, 1), (1, 1)],
            NodeOrientation.TwoSeventy:[(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }
}

//TForm
class TForm: NodeForm {
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(1, 0), (0, 1), (1, 1), (2, 1)],
            NodeOrientation.Nighty:[(0, 0), (0, 1), (1, 1), (0, 2)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (2, 0), (1, 1)],
            NodeOrientation.TwoSeventy:[(1, 0), (0, 1), (1, 1), (1, 2)]
        ]
    }
    
}

class LForm: NodeForm{
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(0, 0), (0, 1), (0, 2), (1, 2)],
            NodeOrientation.Nighty:[(0, 0), (1, 0), (2, 0), (0, 1)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (1, 1), (1, 2)],
            NodeOrientation.TwoSeventy:[(2, 0), (0, 1), (1, 1), (2, 1)]
        ]
    }
}


class JForm: NodeForm{
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(1, 0), (1, 1), (0, 2), (1, 2)],
            NodeOrientation.Nighty:[(0, 0), (0, 1), (1, 1), (2, 1)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (0, 1), (0, 2)],
            NodeOrientation.TwoSeventy:[(0, 0), (1, 0), (2, 0), (2, 1)]
        ]
    }
}

class ZForm: NodeForm{
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(0, 0), (1, 0), (1, 1), (2, 1)],
            NodeOrientation.Nighty:[(1, 0), (0, 1), (1, 1), (0, 2)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (1, 1), (2, 1)],
            NodeOrientation.TwoSeventy:[(1, 0), (0, 1), (1, 1), (0, 2)]
        ]
    }
}


class SForm: NodeForm{
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(1, 0), (2, 0), (0, 1), (1, 1)],
            NodeOrientation.Nighty:[(0, 0), (0, 1), (1, 1), (1, 2)],
            NodeOrientation.OneEighty:[(1, 0), (2, 0), (0, 1), (1, 1)],
            NodeOrientation.TwoSeventy:[(0, 0), (0, 1), (1, 1), (1, 2)]
        ]
    }
}


class LineForm: NodeForm{
    
    override var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [
            NodeOrientation.Zero:[(0, 0), (1, 0), (2, 0), (3, 0)],
            NodeOrientation.Nighty:[(0, 0), (0, 1), (0, 2), (0, 3)],
            NodeOrientation.OneEighty:[(0, 0), (1, 0), (2, 0), (3, 0)],
            NodeOrientation.TwoSeventy:[(0, 0), (0, 1), (0, 2), (0, 3)]
        ]
    }
}


