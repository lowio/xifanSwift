//
//  BackgroundView.swift
//  FLO
//
//  Created by 叶贤辉 on 15/4/10.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    @IBInspectable var lightColor:UIColor = UIColor.yellowColor();
    @IBInspectable var darkColor:UIColor = UIColor.orangeColor();
    @IBInspectable var patternSize:CGFloat = 200;

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext();
        
        let drawSize = CGSize(width: patternSize, height: patternSize);
        
        UIGraphicsBeginImageContext(drawSize);
        let imgContext = UIGraphicsGetCurrentContext();
        lightColor.setFill();
        CGContextFillRect(imgContext, CGRect(origin: CGPoint.zeroPoint, size: drawSize));
        
        
        
        let trianglePath = UIBezierPath()
        //1
        trianglePath.moveToPoint(CGPoint(x:drawSize.width/2,
            y:0))
        //2
        trianglePath.addLineToPoint(CGPoint(x:0,
            y:drawSize.height/2))
        //3
        trianglePath.addLineToPoint(CGPoint(x:drawSize.width,
            y:drawSize.height/2))
        
        //4
        trianglePath.moveToPoint(CGPoint(x: 0,
            y: drawSize.height/2))
        //5
        trianglePath.addLineToPoint(CGPoint(x: drawSize.width/2,
            y: drawSize.height))
        //6
        trianglePath.addLineToPoint(CGPoint(x: 0,
            y: drawSize.height))
        
        //7
        trianglePath.moveToPoint(CGPoint(x: drawSize.width,
            y: drawSize.height/2))
        //8
        trianglePath.addLineToPoint(CGPoint(x:drawSize.width/2,
            y:drawSize.height))
        //9
        trianglePath.addLineToPoint(CGPoint(x: drawSize.width,
            y: drawSize.height))
        
        darkColor.setFill()
        trianglePath.fill()
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIColor(patternImage: img).setFill();
        CGContextFillRect(context, rect);
    }
}
