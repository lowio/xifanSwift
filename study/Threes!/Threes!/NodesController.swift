//
//  ThreesController.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/26.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit

//NodesController
class NodesController {
    
    //节点列表
    private var n2d:Nodes2D
    
    //scene
    private let scene:GameScene
    
    //node层
    private let nodeLayer:NodeLayer
    
    //预览node层
    private let previewLayer:SKShapeNode
    
    //记分文本
    private let scoreLable:SKLabelNode
    
    init(view:SKView, columns:Int, rows:Int)
    {
        
        //GameScene锚点默认在左下角
        self.scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .AspectFill
        view.presentScene(scene)
        
        GameInfo.instance.reset(columns, rows: rows, sceneSize: scene.size, nodeSize: GameConfig.size)
        
        
        self.n2d = Nodes2D(columns:columns, rows:rows)
        
        self.nodeLayer = NodeLayer()
        scene.addChild(nodeLayer)
        
        self.scoreLable = SKLabelNode()
        scoreLable.fontSize = 20
        scoreLable.fontName = GameConfig.fontName
        scoreLable.text = "Score:0"
        scoreLable.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scene.addChild(self.scoreLable)
        
        var previewSize = nodeLayer.frame.size
        previewSize.height = GameConfig.gap * 2 + GameInfo.instance.nodeSize.height
        previewLayer = SKShapeNode(rectOfSize: previewSize, cornerRadius: GameConfig.cornerRadius)
        previewLayer.fillColor = UIColor.grayColor()
        scene.addChild(previewLayer)
        
        updateWhenSizeChanged()
        
        var a2d = Array2D<NodeItemData>(columns: 4, rows: 4)
        a2d[3, 2] = NodeItemData(column: 3, row: 2, level: 4)
        println(a2d)
    }
    
    //当尺寸发生变化 更新
    func updateWhenSizeChanged()
    {
        let info = GameInfo.instance
        var pos = CGPoint(x: (info.sceneSize.width - nodeLayer.size.width)/2, y: (info.sceneSize.height - nodeLayer.size.height)/2)
        nodeLayer.position = pos
        pos.x += GameConfig.gap
        pos.y += nodeLayer.size.height + GameConfig.gap
        scoreLable.position = pos
        pos.x = GameInfo.instance.sceneSize.width * 0.5
        pos.y += scoreLable.frame.height + GameConfig.gap
        previewLayer.position = pos
    }
    
    //更新score
    private func updateScore()
    {
        scoreLable.text = String(PlayerInfo.instance.score)
    }
    
    //＝＝＝＝＝＝＝＝＝＝预览相关＝＝＝＝＝＝＝＝＝＝＝＝
    
    //预览node列表
    private var previews = Array<NodeView>()
    
    //在预览列表中取出一个view
    private func pullViewFromPreviews(index:Int) -> NodeView
    {
        let view = previews.removeAtIndex(index)
        view.display.xScale = 1
        view.display.yScale = 1
        if view.display.parent != nil
        {
            view.display.removeFromParent()
        }
        return view
    }
    
    //在预览列表中随机获取一个view
    private func pullViewFromPreviews() -> NodeView
    {
        var index = ThreesUtil.getRandom(previews.count)
        return pullViewFromPreviews(index)
    }
    
    //清空previews
    private func clearPreviews()
    {
        while !previews.isEmpty
        {
            previews.removeLast().destroySelf()
        }
    }
    
    //创建预览node
    private func createPreviews(count:Int)
    {
        var pos = CGPoint(x: -previewLayer.frame.width * 0.5 + GameConfig.gap, y: -GameConfig.gap)
        for _ in 0..<count
        {
            let scale = GameConfig.scale
            let view = DefaultNodeView.create()
            view.display.xScale = scale
            view.display.yScale = scale
            view.position = pos
            previewLayer.addChild(view.display)
            previews.append(view)
            pos.x += view.display.frame.width * scale + GameConfig.gap
        }
    }
    
    //移动一个随即预览节点并添加到 nodes列表中
    private func movePreviewToNodes(column:Int, row:Int, enterFrom:NodeFromEnum)
    {
        var pos = nodeLayer.getPosition(column, row: row)
        var offset = enterFrom.getOffset()
        pos.x += offset.x
        pos.y += offset.y
        let view = pullViewFromPreviews()
        view.display.position = pos
        let node = n2d.addNode(column, row: row, level: view.level)
        node.view = view
        nodeLayer.addChild(view.display)
        moveNode(node)
        
        if node.level > 1
        {
            PlayerInfo.instance.score += Int(pow(3, Double(view.level - 1)))
            updateScore()
        }
    }
    
    //移动
    private func moveNode(node:NodeItemData)
    {
        node.view?.display.runAction(SKAction.moveTo(nodeLayer.getPosition(node.column, row: node.row), duration: 0.1))
    }
    
    //节点方向
    enum NodeFromEnum:Int
    {
        case Left = 0, Right, Bottom, Top
        
        //获取位置偏移量
        func getOffset() -> CGPoint
        {
            let rate = CGFloat(self.rawValue % 2)
            let s = self.rawValue > 1 ? GameInfo.instance.nodeSize.height : GameInfo.instance.nodeSize.width
            let offset = (rate == 0 ? -4 : 4) * s
            return (self.rawValue > 1 ? CGPoint(x: 0, y: offset) : CGPoint(x: offset, y: 0))
        }
        
        //获取一个随即位置
        static func random() -> NodeFromEnum
        {
            let v = ThreesUtil.getRandom(4)
            return NodeFromEnum(rawValue: v)!
        }
    }

    //移动
    func swipe(direction:UISwipeGestureRecognizerDirection)
    {
        //移动的偏移量
        var movedColumn = 0
        var movedRow = 0
        
        //预览的节点的行或者列
        var cORr = 0
        
        
        //新的node是从边界外移入的， 此值表示边界外的 x或y
        var nodeFrom:NodeFromEnum
        
        switch direction
        {
        case UISwipeGestureRecognizerDirection.Left:
            movedColumn = -1
            nodeFrom = NodeFromEnum.Right
            cORr = GameInfo.instance.columns - 1
        case UISwipeGestureRecognizerDirection.Right:
            nodeFrom = NodeFromEnum.Left
            movedColumn = 1
        case UISwipeGestureRecognizerDirection.Up:
            movedRow = -1
            nodeFrom = NodeFromEnum.Bottom
            cORr = GameInfo.instance.rows - 1
        case UISwipeGestureRecognizerDirection.Down:
            nodeFrom = NodeFromEnum.Top
            movedRow = 1
        default:
            return
        }
        
        let temp = n2d.moveNodes(movedColumn: movedColumn, movedRow: movedRow)
        movedPositions = temp.0
        removedList = temp.1
        if let pos = validateMoved()
        {
            var p = pos
            movedRow != 0 ? (p.1 = cORr) : (p.0 = cORr)
            movePreviewToNodes(p.0, row: p.1, enterFrom: nodeFrom)
            clearPreviews()
            let maxPreviewCount = PlayerInfo.instance.level > 7 ? ThreesUtil.getRandom(3)+1:1
            createPreviews(maxPreviewCount)
        }
    }
    
    //可移动的点
    private var movedPositions:Array<(Int, Int)> = []
    
    //可以删除的点
    private var removedList:Array<NodeItemData> = []
    
    //移动行为生效
    private func validateMoved() -> (Int, Int)?
    {
        //移动生效
        n2d.validate()
        
        //下一个空闲位置
        var next:(Int, Int)?
        if !removedList.isEmpty
        {
            let n = ThreesUtil.getRandom(removedList)
            next = (n.column, n.row)
        }
        
        if next == nil && !movedPositions.isEmpty
        {
            let n = ThreesUtil.getRandom(movedPositions)
            next = n
        }
        
        while !movedPositions.isEmpty
        {
            var temp = movedPositions.removeLast()
            if let n = n2d.updateNode(temp.0, row: temp.1)
            {
                if n.validateMerge()
                {
                    if PlayerInfo.instance.level < n.level
                    {
                        PlayerInfo.instance.level = n.level
                        println("此处更新最大级别变更后 对数字颜色的影响")
                    }
                }
                moveNode(n)
            }
        }
        
        nodeLayer.runAction(SKAction.waitForDuration(0.2), completion: validateRemoved)
        
        
        return next
    }
    
    //删除节点生效
    private func validateRemoved()
    {
        for n in removedList
        {
            n.destroySelf()
        }
        removedList.removeAll(keepCapacity: false)
    }
    
    //恢复移动之前的数据
    private func recoverMove()
    {
        n2d.recover()
        self.removedList.removeAll(keepCapacity: false)
        self.movedPositions.removeAll(keepCapacity: false)
    }
  
    //开始
    func start()
    {
        let count:Int = 4
        PlayerInfo.instance.reset()
        
        createPreviews(count)
        n2d.calculateAllIdles()
        
        while !previews.isEmpty
        {
            if let pos = n2d.getRandomIdle()
            {
                movePreviewToNodes(pos.column, row: pos.row, enterFrom: NodeFromEnum.random())
            }
            else
            {
                break
                
            }
        }
        
        createPreviews(1)
    }
    
    //游戏结束
    private func gameOver()
    {
        println("game over")
    }
    
}