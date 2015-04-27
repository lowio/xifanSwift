//
//  SwiftTrisManager.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/29.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation


let columns = 10
let rows = 20

class SwiftTrisManager {
    
    //node节点列表
    var a2d:Array2D<Node>
    
    //当前正在降落的nodeform
    var fallingForm:NodeForm?
    
    //预览nodeform（下一次准备降落的）
    var previewForm:NodeForm?
    
    var delegate:SwiftTrisDelegate?
    
    init(delegate:SwiftTrisDelegate)
    {
        a2d = Array2D(columns: columns, rows: rows)
        fallingForm = nil
        previewForm = nil
        self.delegate = delegate
    }
    
    //下一个nodeform
    func next()
    {
        fallingForm = previewForm
        previewForm = NodeFormEnum.getRandomForm(columns, row: 0)
        if fallingForm == nil
        {
            next()
            return
        }
        
        fallingForm?.move(((columns-1) >> 1), toRow: 0)
        if checkNextRow()
        {
            delegate?.gameOver(self)
        }
    }
    
    //自动降落
    func autoFall()
    {
        if let f = fallingForm
        {
            if !checkNextRow()
            {
                f.down()
                delegate?.fall(self)
            }
            else
            {
                fallComplete()
                delegate?.next(self)
            }
        }
    }
    
    //一次到底
    func fallBottom()
    {
        if let f = fallingForm
        {
            while !checkNextRow()
            {
                f.down()
            }
            
            fallComplete()
            delegate?.next(self)
        }
    }
    
    func fallLeft()
    {
        if let f = fallingForm
        {
            f.left()
            if checkCurrentRow()
            {
                f.right()
                return
            }
            delegate?.fall(self)
        }
    }
    
    func fallRight()
    {
        if let f = fallingForm
        {
            f.right()
            if checkCurrentRow()
            {
                f.left()
                return
            }
            delegate?.fall(self)
        }
    }
    
    func fallClockwise()
    {
        if let f = fallingForm
        {
            f.rotate(true)
            if checkCurrentRow()
            {
                f.rotate(false)
                return
            }
            delegate?.fall(self)
        }
    }
    
    func fallAntiClockwise()
    {
        if let f = fallingForm
        {
            f.rotate(false)
            if checkCurrentRow()
            {
                f.rotate(true)
                return
            }
            delegate?.fall(self)
        }
    }
    
    //检测边界
    func checkCurrentRow() -> Bool
    {
        if let ns = fallingForm?.bottomNodes
        {
            for (key , n) in ns
            {
                if (n.row > rows - 1 || n.column > columns - 1 || n.row < 0 || n.column < 0)
                {
                    return true
                }
                else if a2d[n.column, n.row] != nil
                {
                    return true
                }
            }
        }
        return false
    }
    
    //检测碰撞边界或碰撞到form （碰撞后 添加到列表中)
    func checkNextRow() -> Bool
    {
        if let ns = fallingForm?.bottomNodes
        {
            for (key , n) in ns
            {
                let nextRow = n.row + 1
                if nextRow > rows - 1 || a2d[n.column, nextRow] != nil{
                    return true
                }
            }
        }
        return false
    }
    
    func fallComplete()
    {
        if let f = fallingForm{
            
            var addRows:String = ""
            for n in f.nodeList{
                a2d[n.column, n.row] = n
            }
            
            for n in f.nodeList{
                checkRow(n.row)
            }

        }
    }
    
    
    func checkRow(row:Int) -> Bool
    {
        if let ns = a2d.getNodesByRow(row)
        {
            if ns.count >= columns
            {
                for (c, n) in ns{
                    n.display?.removeFromParent()
                    n.display = nil
                    a2d[c, row] = nil
                }
                return true
            }
        }
        return false
    }
    
}
