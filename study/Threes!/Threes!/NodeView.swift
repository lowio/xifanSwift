//
//  NodeItem.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/11.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit

//nodeview 协议
protocol NodeView
{
    //级别
    var level:Int { set get }
    
    //显示对象
    var display:SKNode{ get }
    
    //销毁自己
    func destroySelf()
}

class DefaultNodeView: NodeShapeView, NodeView {
    
    //文本
    let contentLable:SKLabelNode!
    
    var display:SKNode{
        return self
    }
    
    var level:Int{
        willSet{
            update(newValue)
        }
    }
    
    init(level:Int) {
        contentLable = SKLabelNode(fontNamed: GameConfig.fontName)
        contentLable.fontSize = CGFloat(GameConfig.fontSize)
        contentLable.text = "0"
        contentLable.position = CGPoint(x: GameConfig.size.width/2, y: (GameConfig.size.height - contentLable.frame.height)/2)
        
        self.level = level
        
        super.init(size:GameConfig.size)
        self.strokeColor = UIColor.blackColor()
        update(level, force: true)
        self.path = ThreesUtil.drawRoundedRects([CGRect(origin: CGPoint(), size: GameConfig.size)])
        self.addChild(contentLable)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //更新界面 但是不给level赋值
    private func update(newLevel:Int, force:Bool = false)
    {
        if newLevel < 2
        {
            contentLable.fontColor = UIColor.whiteColor()
        }
        else if newLevel == PlayerInfo.instance.level
        {
            contentLable.fontColor = UIColor.redColor()
        }
        else
        {
            contentLable.fontColor = UIColor.blackColor()
        }
        
        if newLevel == level && !force
        {
            return
        }
        
        if newLevel > 1
        {
            self.fillColor = UIColor.whiteColor()
        }
        else if newLevel == 1
        {
            self.fillColor = UIColor.blueColor()
        }
        else
        {
            self.fillColor = UIColor.redColor()
        }
        
        contentLable.text = String(NodeItemData.getValue(newLevel))
    }
    
    func destroySelf()
    {
        if self.parent != nil
        {
            self.removeFromParent()
            nsObjPool.recycle(self)
        }
    }
    
    class func create() -> DefaultNodeView
    {
        let level = ThreesUtil.getRandom(PlayerInfo.instance.level)
        if let temp = nsObjPool.get(DefaultNodeView)
        {
            var view = temp as! DefaultNodeView
            view.level = level
            return view
        }
        return DefaultNodeView(level: level)
    }
}

//node shape基类
class NodeShapeView: SKShapeNode {
    
    //重置
    override var position:CGPoint{
        willSet{
            if newValue == position
            {
                return
            }
            setFrame()
        }
    }
    
    override var frame:CGRect{
        return self._frame
    }
    
    //尺寸
    var size:CGSize{
        willSet{
            if newValue == size
            {
                return
            }
            setFrame()
            updateWhenSizeChanged()
        }
    }
    
    //rect
    private var _frame:CGRect
    
    init(size:CGSize)
    {
        self.size = size
        _frame = CGRect()
        super.init()
        setFrame()
        updateWhenSizeChanged()
    }
    
    //更新frame
    final private func setFrame()
    {
        _frame = CGRect(origin: position, size: size)
    }
    
    //更新 子类覆盖
    func updateWhenSizeChanged()
    {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}