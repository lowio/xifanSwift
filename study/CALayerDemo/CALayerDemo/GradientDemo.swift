//
//  GradientDemo.swift
//  CALayerDemo
//
//  Created by 叶贤辉 on 15/3/31.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import UIKit;

//渐变色
class GradientDemo: UIView {
    
    override init() {
        super.init(frame: CGRect(x: 20, y: 40, width: 300, height: 300));
        
        var l = CAGradientLayer();
        l.frame = self.bounds;
        l.colors = [cgColorForRed(209.0, green: 0.0, blue: 0.0),
            cgColorForRed(255.0, green: 102.0, blue: 34.0),
            cgColorForRed(255.0, green: 218.0, blue: 33.0),
            cgColorForRed(51.0, green: 221.0, blue: 0.0),
            cgColorForRed(17.0, green: 51.0, blue: 204.0),
            cgColorForRed(34.0, green: 0.0, blue: 102.0),
            cgColorForRed(51.0, green: 0.0, blue: 68.0)];
        
        l.startPoint = CGPoint(x: 0, y: 0);
        l.endPoint = CGPoint(x: 1, y: 1);
        self.layer.addSublayer(l);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cgColorForRed(red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).CGColor as AnyObject
    }
}