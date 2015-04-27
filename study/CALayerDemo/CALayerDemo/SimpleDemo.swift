//
//  SimpleDemo.swift
//  CALayerDemo
//
//  Created by 叶贤辉 on 15/3/31.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import UIKit

//简单的view
class SimpleView: UIView {
    
    private var _l:CALayer!;
    
    private var l:CALayer{
        return _l;
    }
    
    override init() {
        super.init(frame: CGRect(x: 20, y: 50, width: 200, height: 200));
        
//        _l = self.layer;  //可以设置为本身自带的layer
        _l = CALayer();
        _l.frame = self.bounds;
        self.layer.addSublayer(_l);
        
        setupLayer();
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置layer
    private func setupLayer()
    {
//        l.backgroundColor = UIColor.blueColor().CGColor;
        l.backgroundColor = UIColor(red: 11/255.0, green: 86/255.0, blue: 14/255.0, alpha: 1.0).CGColor;
        l.borderWidth = 12;
        l.borderColor = UIColor.whiteColor().CGColor;
        l.cornerRadius = 100;
        
        l.opacity = 1; //透明度
        l.hidden = false; //是否隐藏
        l.masksToBounds = false;    //内容是否根据bounds来进行遮罩 false：不遮罩， true：只显示bounds范围内的内容
        
        l.magnificationFilter = kCAFilterLinear;
        l.geometryFlipped = false;
        
        l.shadowOpacity = 0.7;
        l.shadowRadius = 3;
        l.shadowOffset = CGSize(width: 0, height: 3)
        
        l.contents = UIImage(named: "star")?.CGImage;
        l.contentsGravity = kCAGravityCenter;
//        l.contentsGravity = kCAGravityLeft;
    }
    
}

