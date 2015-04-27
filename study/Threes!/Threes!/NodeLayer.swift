//
//  NodeItemLayer.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/11.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit

//node对象对象容器层
class NodeLayer: NodeShapeView {
    
    init()
    {
        let info = GameInfo.instance
        let c = CGFloat(info.columns)
        let r = CGFloat(info.rows)
        let w = c * (info.nodeSize.width + GameConfig.gap) - GameConfig.gap
        let h = r * (info.nodeSize.height + GameConfig.gap) - GameConfig.gap
        
        super.init(size:CGSize(width:w, height:h))
        
        self.strokeColor = UIColor.whiteColor()
        self.fillColor = UIColor.grayColor()
    }
    
    override func updateWhenSizeChanged() {
        //将要渲染的矩形
        var rects = [CGRect]()
        for r in 0..<GameInfo.instance.rows
        {
            for c in 0..<GameInfo.instance.columns
            {
                rects.append(CGRect(origin: getPosition(c, row: r), size: GameInfo.instance.nodeSize))
            }
        }
        self.path = ThreesUtil.drawRoundedRects(rects)
    }
    
    //根据行列获取位置
    func getPosition(column:Int, row:Int) -> CGPoint
    {
        let info = GameInfo.instance
        let r = CGFloat(info.rows - 1 - row)
        let x = CGFloat(column) * (info.nodeSize.width + GameConfig.gap)
        let y = r * (info.nodeSize.height + GameConfig.gap)
        return CGPoint(x: x, y: y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}