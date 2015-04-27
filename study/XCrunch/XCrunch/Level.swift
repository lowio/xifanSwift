//
//  Level.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation


let numColumns = 9;
let numRows = 9;


//等级
class Level {
    
    //node列表
    private var nodes = Array2D<XNodeData>(columns: numColumns, rows: numRows);
    
    //获取指定位置的 xnode
    func getNodeAt(column:Int, row:Int) -> XNodeData?
    {
        assert(column >= 0 && column < numColumns);
        assert(row >= 0 && row < numRows);
        return nodes[column, row];
    }
    
    func createNodes() -> Set<XNodeData>
    {
        var set:Set<XNodeData>;
        do
        {
        set = createInitialNodes();
        detectPossibleSwapNodes();
        }
        while possibleSwapNodes.isEmpty
        return set;
    }
    
    //创建初始化node列表
    private func createInitialNodes() -> Set<XNodeData>
    {
        var set = Set<XNodeData>();
        
        for row in 0..<numRows
        {
            var str = "";
            for column in 0..<numColumns
            {
                if getTileAt(column, row: row) == nil
                {
                    continue;
                }
                let t = getRandomType(column, row: row);
                let n = XNodeData(column: column, row: row, type: t);
                nodes[column, row] = n;
                set.insert(n);
            }
        }
        return set;
    }
    
    //获取随机类型
    private func getRandomType(column:Int, row:Int) -> XNodeType
    {
        var t:XNodeType!
        do{
            t = XNodeType.random();
        }
        while (column > 1 && nodes[column - 1, row]?.nodeType == t && nodes[column - 2, row]?.nodeType == t)
            ||
            (row > 1 && nodes[column, row - 1]?.nodeType == t && nodes[column, row - 2]?.nodeType == t)
        
        return t;
    }
    
    //生效
    func validateSwipe(swipe:Swap)
    {
        
        let fc = swipe.current.column;
        let fr = swipe.current.row;
        
        let tc = swipe.target.column;
        let tr = swipe.target.row;
        
        nodes[fc, fr] = swipe.target;
        swipe.target.column = fc;
        swipe.target.row = fr;
        
        nodes[tc, tr] = swipe.current;
        swipe.current.column = tc;
        swipe.current.row = tr;
    }
    
    //指定位置的node是否 存在一个链（三个或以上 type的node）
    private func nodeInChian(column:Int, row:Int) -> Bool
    {
        if let type = nodes[column, row]?.nodeType
        {
            var columnCount = 1;
            //向左检测
            for var c = column - 1; c >= 0 && type == nodes[c, row]?.nodeType; c--, columnCount++ {}
            //向右检测
            for var c = column + 1; c < numColumns && type == nodes[c, row]?.nodeType; c++, columnCount++ {}
            
            if columnCount > 2 { return true; }
            
            var rowCount = 1;
            //向下检测
            for var r = row - 1; r >= 0 && type == nodes[column, r]?.nodeType; r--, rowCount++ {}
            //向上检测
            for var r = row + 1; r < numRows && type == nodes[column, r]?.nodeType; r++, rowCount++ {}
            
            if rowCount > 2 { return true; }
        }
        return false;
    }
    
    //可以移动的node列表
    var possibleSwapNodes:Set<Swap>!;
    
    //发现可移动的node列表
    func detectPossibleSwapNodes()
    {
        var set = Set<Swap>();
        for r in 0..<numRows
        {
            for c in 0..<numColumns
            {
                if let current = nodes[c, r]
                {
                    //水平方向
                    if c < numColumns - 1
                    {
                        if let swap = calculateTwo(current, column: c + 1, row: r)
                        {
                            set.insert(swap);
                        }
                    }
                    
                    if r < numRows - 1
                    {
                        if let swap = calculateTwo(current, column: c, row: r + 1)
                        {
                            set.insert(swap);
                        }
                    }
                }
               
                
            }
        }
        possibleSwapNodes = set;
    }
    
    //计算两个node是否可以移动
    private func calculateTwo(node:XNodeData, column:Int, row:Int) -> Swap?
    {
        if let next = nodes[column, row]
        {
            nodes[node.column, node.row] = next;
            nodes[column, row] = node;
            
            var swipe:Swap?;
            if nodeInChian(column, row: row) || nodeInChian(node.column, row: node.row)
            {
                swipe = Swap(current: node, target: next);
            }
            
            nodes[node.column, node.row] = node;
            nodes[column, row] = next;
            return swipe;
        }
        return nil;
    }
    
    //是否能够移动
    func isPossibleSwap(swipe:Swap) -> Bool
    {
        return possibleSwapNodes.contains(swipe);
    }
    
    //可消除的链chian====================
    
    //发现水平chian
    private func detectHorizontalChian() -> Set<Chian>
    {
        var set = Set<Chian>();
        for row in 0..<numRows
        {
            for var column:Int = 0; column < numColumns-2;
            {
                if let node = nodes[column, row] where
                    (node.nodeType == nodes[column + 1, row]?.nodeType) &&
                    (nodes[column + 2, row]?.nodeType == node.nodeType)
                {
                    var nodeType = node.nodeType;
                    let chian = Chian(chianType: Chian.ChianType.Horizontal);
                    do
                    {
                    chian.addNode(nodes[column, row]!);
                    ++column
                    }
                    while column < numColumns && nodeType == nodes[column, row]?.nodeType
                    set.insert(chian);
                    continue;
                }
                column++;
                
            }
        }
        return set;
    }
    
    //发现竖直chian
    private func detectVerticalChian() -> Set<Chian>
    {
        var set = Set<Chian>();
        for column in 0..<numColumns
        {
            for var row:Int = 0; row < numRows-2;
            {
                if let node = nodes[column, row] where (node.nodeType == nodes[column, row+1]?.nodeType) &&
                (node.nodeType == nodes[column, row + 2]?.nodeType)
                {
                    let nodeType = node.nodeType;
                    let chian = Chian(chianType: Chian.ChianType.Vertical);
                    do
                    {
                    chian.addNode(nodes[column, row]!);
                    row++;
                    }while row < numRows && nodeType == nodes[column, row]?.nodeType
                    set.insert(chian);
                    continue
                }
                row++;
            }
        }
        return set;
    }
    
    //获取chian Set
    func getChianSet() -> Set<Chian>
    {
        let hChian = detectHorizontalChian();
        let vChian = detectVerticalChian();
        removeChians(hChian);
        removeChians(vChian);
        return hChian.union(vChian);
    }
    
    //移除chian 
    private func removeChians(chianSet:Set<Chian>)
    {
        for chian in chianSet
        {
            for node in chian.nodes
            {
                nodes[node.column, node.row] = nil;
            }
        }
    }
    
    //掉落剩下的
    func fallDownRemaining() -> [[XNodeData]]
    {
        var fallNodes = [[XNodeData]]();
        
        for column in 0..<numColumns
        {
            var arr = [XNodeData]();
            for row in 0..<numRows
            {
                if nodes[column, row] == nil && tiles[column, row] != nil
                {
                    for nextRow in row+1 ..< numRows
                    {
                        if let next = nodes[column, nextRow]
                        {
                            nodes[column, nextRow] = nil;
                            next.row = row;
                            nodes[column, row] = next;
                            arr.append(next);
                            break;
                        }
                    }
                }
            }
            
            if arr.isEmpty
            {
                continue;
            }
            fallNodes.append(arr);
        }
        
        return fallNodes;
    }
    //======================填充新的node
    //填充满
    func fillTheNilSpace() -> [[XNodeData]]
    {
        var fillNodes = [[XNodeData]]();
        var nodeType = XNodeType.UnKnown;
        for column in 0..<numColumns
        {
            var arr = [XNodeData]();
            for var row = numRows - 1; row > -1 && nodes[column, row] == nil; row--
            {
                if tiles[column, row] == nil { continue; }
                var type:XNodeType;
                do{
                type = XNodeType.random();
                }while type == nodeType;
                nodeType = type;
                
                let node = XNodeData(column: column, row: row, type: nodeType);
                nodes[column, row] = node;
                arr.append(node);
            }
            
            if arr.isEmpty {continue;}
            fillNodes.append(arr);
        }
        
        return fillNodes;
    }
    
    
    
    //===============================
    //tile列表
    private var tiles:Array2D<XTileData>!;
    
    //获取指定位置的tile
    func getTileAt(column:Int, row:Int) -> XTileData?
    {
        assert(column >= 0 && column < numColumns);
        assert(row >= 0 && row < numRows);
        return tiles[column, row];
    }
    
    init(fileName:String)
    {
        self.loadLevel(fileName);
    }
    
    //重置tiles
    private func resetTiles()
    {
        tiles = Array2D<XTileData>(columns: numColumns, rows: numRows);
    }
    
    //加载等级
    func loadLevel(fileName:String)
    {
        resetTiles();
//        if let jsonParser = JSONParser.create(fileName, directory: "Levels")
//        {
//            if let ta = jsonParser["tiles"].arrayValue
//            {
//                for (r, rows) in enumerate(ta)
//                {
//                    let row = numRows - r - 1;
//                    if let columns = rows.arrayValue
//                    {
//                        for (column, flag) in enumerate(columns)
//                        {
//                            if flag.intValue == 1
//                            {
//                                tiles[column, r] = XTileData();
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        if let td = Dictionary<String, AnyObject>.loadJSONData(fileName)
        {
            if let ta: AnyObject = td["tiles"]
            {
                for (row, rows) in enumerate(ta as! [[Int]])
                {
                    let r = numRows - row - 1;  //最底部一行才是第0行
                    for (column, flag) in enumerate(rows)
                    {
                        if flag == 1
                        {
                            tiles[column, r] = XTileData();
                        }
                    }
                }
            }
        }
    }
}