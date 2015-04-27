//
//  Nodes2D.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/3/5.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit

struct Nodes2D {
    typealias NodeType = NodeItemData
    
    //nods列表
    private var a2d:Array2D<NodeType>
    
    init(columns:Int, rows:Int)
    {
        a2d = Array2D<NodeType>(columns: columns, rows: rows)
    }
    
    private var allIdles:[Int] = []
    
    //计算出所有的空闲位置
    mutating func calculateAllIdles() -> [Int]
    {
        allIdles = []
        let total = a2d.count
        for i in 0..<total
        {
            if a2d[i] == nil
            {
                allIdles.append(i)
            }
        }
        return allIdles
    }
    
    //随即一个空闲位置
    mutating func getRandomIdle() -> (column:Int, row:Int)?
    {
        if allIdles.isEmpty
        {
            return nil
        }
        
        let index = ThreesUtil.getRandom(allIdles.count)
        let idleValue = allIdles.removeAtIndex(index)
        return a2d.convert(value2Position: idleValue)
    }
    
    //回滚
    mutating func recover()
    {
        a2d.recover()
    }
    
    //制作副本
    mutating func invalidate()
    {
        a2d.invalidate()
    }
    
    //移动生效
    mutating func validate()
    {
        a2d.validate()
    }
    
    //重置
    mutating func reset()
    {
        a2d = Array2D<NodeType>(columns: a2d.columns, rows: a2d.rows)
        allIdles.removeAll(keepCapacity: false)
    }
}

//操作具体节点
extension Nodes2D
{
    //新增一个node
    mutating func addNode(column:Int, row:Int, level:Int) -> NodeType
    {
        let node = NodeType.create(column, row: row, level: level)
        a2d[column, row] = node
        return node
    }
    
    //更新节点的位置
    mutating func updateNode(column:Int, row:Int) -> NodeType?
    {
        if let node = a2d[column, row]
        {
            node.column = column
            node.row = row
            return node
        }
        return nil
    }
}

//移动
extension Nodes2D
{
    //移动所有节点
    mutating func moveNodes(movedColumn mc:Int, movedRow mr:Int) -> (Array<(Int, Int)>, Array<NodeType>)
    {
        invalidate()
        
        let columnOffset = mc > 0 ? -1 : 1
        let rowOffset = mr > 0 ? -1 : 1
        
        let c = mc > 0 ? a2d.columns - 1 : 0
        let r = mr > 0 ? a2d.rows - 1 : 0
        
        //将要删除的节点
        var removedList:Array<NodeType> = []
        var movedPositions:Array<(Int, Int)> = []
        
        var column = c
        var row = r
        for _ in 0..<a2d.columns
        {
            row = r
            for _ in 0..<a2d.rows
            {
                moveNode(column, row: row, movedColumn: mc, movedRow: mr, mList: &movedPositions,rmList: &removedList)
                row += rowOffset
            }
            column += columnOffset
        }
        return (movedPositions, removedList)
    }
    
    //移动当前节点
    mutating func moveNode(column:Int, row:Int, movedColumn mc:Int, movedRow mr:Int,
        inout mList:Array<(Int, Int)>, inout rmList:Array<NodeType>)
    {
        let targetColumn = column + mc
        let targetRow = row + mr
        
        if outOfBounds(column: targetColumn) || outOfBounds(row: targetRow)
        {
            return
        }
        
        if let cn = a2d[column, row]
        {
            if let tn = a2d[targetColumn, targetRow]
            {
                if cn.invalidateMerge(mergeLevel: tn.level)
                {
                    rmList.append(tn)
                }
                else
                {
                    return
                }
            }
            
            a2d[column, row] = nil
            a2d[targetColumn, targetRow] = cn
            mList.append((targetColumn, targetRow)) //目标节点无node 所以current可以移动
        }
    }
    
    //是否超出边界
    private func outOfBounds(column c:Int) -> Bool
    {
        return c < 0 || c >= a2d.columns
    }
    
    //是否超出边界
    private func outOfBounds(row r:Int) -> Bool
    {
        return r < 0 || r >= a2d.rows
    }
}