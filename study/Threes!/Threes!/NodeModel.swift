//
//  NodeData.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/11.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//=====================NodeItemData 可以根据需要添加 障碍位置列表========================

//node item data
class NodeItemData:NSObject {
    
    //行列
    var column, row:Int
    
    //等级
    var level:Int{
        willSet{
            if level != newValue
            {
                value = NodeItemData.getValue(newValue)
            }
            
            if view != nil
            {
                view!.level = newValue
            }
        }
    }
    
    //权重值
    var value:Int = -1
    
    //显示对象
    var view:NodeView?
    
    init(column:Int, row:Int, level:Int)
    {
        self.column = column
        self.row = row
        self.level = level
        value = NodeItemData.getValue(level)
    }
    
    private var mergedLevel:Int = -1
    //合成标记失效
    func invalidateMerge(mergeLevel l:Int) -> Bool
    {
        if level + l == 1
        {
            mergedLevel = 2
            return true
        }
        else if level > 1 && level == l
        {
            mergedLevel = level + 1
            return true
        }
        return false
    }
    
    //合成生效
    func validateMerge() -> Bool
    {
        if mergedLevel != -1
        {
            if mergedLevel != level
            {
                level = mergedLevel
            }
            mergedLevel = -1
            return true
        }
        return false
    }
    
    //根据等级获取value
    class func getValue(level:Int) -> Int
    {
        if level < 2
        {
            return level + 1
        }
        else
        {
            return (3<<(level-2))
        }
    }
}

extension NodeItemData
{
    //销毁自己
    func destroySelf()
    {
        if view != nil
        {
            view!.destroySelf()
            view = nil
        }
        nsObjPool.recycle(self)
    }
    
    //创建一个item
    class func create(column:Int, row:Int, level:Int) -> NodeItemData
    {
        if let temp = nsObjPool.get(NodeItemData)
        {
            var item = temp as! NodeItemData
            item.column = column
            item.row = row
            item.level = level
            return item
        }
        
        return NodeItemData(column: column, row: row, level: level)
    }
}


//=====================array2D========================





