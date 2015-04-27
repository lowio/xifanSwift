//
//  GraphView.swift
//  FLO
//
//  Created by 叶贤辉 on 15/4/1.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var startColor:UIColor = UIColor.redColor();
    @IBInspectable var endColor:UIColor = UIColor.blueColor();
    
    //每天次数数组
    var counterPoints: [Int] = [4, 2, 6, 4, 5, 8, 3]{
        didSet{
            setNeedsDisplay();
        }
    };
    
    
    
   
    
    override func drawRect(rect: CGRect) {
        let w = bounds.width;
        let h = bounds.height;
        
        //剪裁
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 8, height: 8));
        path.addClip();
        
        
        
        //get current context!
        let context = UIGraphicsGetCurrentContext();
        let colors = [startColor.CGColor, endColor.CGColor];
        
        //color space
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        //color location from 0 to 1
        let colorLocationRange:[CGFloat] = [0, 1];
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocationRange);
        
        var startPoint = CGPoint.zeroPoint;
//        var endPoint = CGPoint(x: self.bounds.width, y: self.bounds.height);
        var endPoint = CGPoint(x: 0, y: self.bounds.height);
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions.allZeros);
        
        
        let hPadding:CGFloat = 20;
        let hspacer = (w - hPadding * 2)/CGFloat(counterPoints.count - 1);
        var getXByColumn = {(column:Int) -> CGFloat in
            return hspacer * CGFloat(column) + hPadding;
        };
        
        let topPadding:CGFloat = 60;
        let bottomPadding:CGFloat = 50;
        let maxCount = maxElement(counterPoints);
        let vspacer = h - topPadding - bottomPadding;
        var getYByCount = {(count:Int) -> CGFloat in
            var y = CGFloat(count)/CGFloat(maxCount) * vspacer;
            y = vspacer + topPadding - y;
            return y;
        };
        
        UIColor.whiteColor().setFill();
        UIColor.whiteColor().setStroke();
        var countPath = UIBezierPath();
        
        countPath.moveToPoint(CGPoint(x: getXByColumn(0), y: getYByCount(counterPoints[0])));
        
        for i in 1..<counterPoints.count
        {
            countPath.addLineToPoint(CGPoint(x: getXByColumn(i), y: getYByCount(counterPoints[i])));
        }
        
        
//        countPath.stroke();
        
        var clipPath = countPath.copy() as! UIBezierPath;
        clipPath.addLineToPoint(CGPoint(x: getXByColumn(counterPoints.count - 1), y: h));
        clipPath.addLineToPoint(CGPoint(x: getXByColumn(0), y: h));
        clipPath.closePath();
//        clipPath.stroke();
        CGContextSaveGState(context);   //记住当前context（在没有addclip之前的context）
        
        clipPath.addClip();
        
        UIColor.greenColor().setFill();
        let rectpath = UIBezierPath(rect: bounds);
        rectpath.fill();
        
        
        startPoint = CGPoint(x: 0, y: getYByCount(maxCount));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        
        CGContextRestoreGState(context);//恢复到addclip之前的context
        
        countPath.lineWidth = 2;
        countPath.stroke();
        
        UIColor.whiteColor().setFill();
        for i in 0..<counterPoints.count
        {
            let s:CGFloat = 5;
            var p = CGPoint(x: getXByColumn(i), y: getYByCount(counterPoints[i]));
            p.x -= s/2;
            p.y -= s/2;
            
            let pt = UIBezierPath(ovalInRect: CGRect(origin: p, size: CGSize(width: s, height: s)));
            pt.fill();
        }
    }

}
