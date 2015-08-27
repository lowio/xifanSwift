//: Playground - noun: a place where people can play

import UIKit

// the type of path node
struct PathNode: Hashable {
    var column, row:Int;
    
    var hashValue:Int{
        return column ^ row;
    }
}


func ==(lhs:PathNode, rhs:PathNode) -> Bool
{
    return lhs.column == rhs.column && lhs.row == rhs.row;
}

var openList:[PathNode]!;

var closedList = Set<PathNode>();

var obstructionList = Set<PathNode>();



func find(originalNode:PathNode, targetNode:PathNode) -> [PathNode]?
{
    openList = [originalNode];
    closedList.removeAll(keepCapacity: false);
    
    var path:[PathNode]?;
    
    while !openList.isEmpty
    {
        let currentNode = openList.removeAtIndex(0);
        closedList.insert(currentNode);
        
        //查找临近方块
        
        
    }
    
    
    
    
    return path;
}


//查找相邻node top -> left -> bottom -> right
func findAdjacentNodes(aroundNode:PathNode) -> [PathNode]?
{
    var adjacentNodes:[PathNode] = [];
    
    var adjacentNode:PathNode;
    
    adjacentNode = (aroundNode.column, aroundNode.row - 1); //top
    
//    if isLegal(adjacentNode) && !contains(closedList, adjacentNode) && !contains(obstructionList, adjacentNode)
//    {
//        
//    }
    
    
    return nil;
}

func findAdjacentNode(aroundNode: PathNode, column:Int, row:Int) -> PathNode?
{
    var n:PathNode = (aroundNode.column + column, aroundNode.row + row);
    if !isLegal(n)
    {
        return nil;
    }
    
    
    return nil;
}

//节点是否是合法的
func isLegal(ofNode:PathNode) -> Bool
{
    return ofNode.column >= 0 && ofNode.column < 100 && ofNode.row >= 0 && ofNode.row < 100;
}
