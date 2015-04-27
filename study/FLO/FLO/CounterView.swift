//
//  CounterView.swift
//  FLO
//
//  Created by 叶贤辉 on 15/3/31.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit

let maxCount = 8;

let π = CGFloat(M_PI);

@IBDesignable

class CounterView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var counter:Int = 5{
        didSet{
            if counter <= maxCount
            {
                setNeedsDisplay();
            }
        }
    }//当前次数
    @IBInspectable var outlineColor:UIColor = UIColor.blueColor();
    @IBInspectable var counterColor:UIColor = UIColor.orangeColor();
    
    override func drawRect(rect: CGRect) {
        let arcSize:CGFloat = 76;
        let center = CGPoint(x: bounds.width / 2, y: bounds.height/2);
        let radius = (bounds.width - arcSize)/2;
        let startAngle:CGFloat = 3 * π/4;
        let endAngle:CGFloat = π/4;
        
        var arcPath  = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true);
        
        arcPath.lineWidth = arcSize;
        counterColor.setStroke();
        arcPath.stroke();
        
        //起点和终点中间的弧度差值
        let angleAmount:CGFloat = 2 * π - startAngle + endAngle;
        
        //每个count 的弧度大小
        let arcAnglePreCount:CGFloat = angleAmount / CGFloat(maxCount);
        
        //当前counter对应的 终点弧度值
        let outLineEndAngle:CGFloat = startAngle + CGFloat(counter) * arcAnglePreCount;
        
        var outlinePath = UIBezierPath(arcCenter: center, radius: bounds.width / 2 - 2.5, startAngle: startAngle, endAngle: outLineEndAngle, clockwise: true);
        outlinePath.addArcWithCenter(center, radius: bounds.width / 2 - arcSize + 2.5, startAngle: outLineEndAngle, endAngle: startAngle, clockwise: false);
        
        
        
        outlinePath.closePath();
        outlinePath.lineWidth = 5;
        outlineColor.setStroke();
        outlinePath.stroke();
        
        
        UIColor.blackColor().setFill();
        let markPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 5, height: 10));
        let context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, -π/4);
        
        markPath.fill();
        
        
    }

}
