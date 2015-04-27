//
//  PushButtonView.swift
//  FLO
//
//  Created by 叶贤辉 on 15/3/31.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit


@IBDesignable           //设计模式 在storyboard中即时显示结果



class PushButtonView: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    //添加后@IBInspectable 在属性栏能看到这两个值 必须注明类型
    @IBInspectable var fillColor:UIColor = UIColor.greenColor();
    @IBInspectable var isAddButton:Bool = true;
    
    override func drawRect(rect: CGRect) {
        var path = UIBezierPath(ovalInRect: rect);
        fillColor.setFill();
        path.fill();
        
        
        let plusWidth:CGFloat = 45;
        let plusHeight:CGFloat = 3;
        
        var plusPath = UIBezierPath();
        plusPath.lineWidth = plusHeight;
        
        plusPath.moveToPoint(CGPoint(x: (bounds.width - plusWidth)/2, y: bounds.height/2));
        plusPath.addLineToPoint(CGPoint(x: (bounds.width + plusWidth)/2, y: bounds.height/2));
        
        if isAddButton
        {
            plusPath.moveToPoint(CGPoint(x: (bounds.width)/2, y: (bounds.height - plusWidth)/2));
            plusPath.addLineToPoint(CGPoint(x: (bounds.width)/2, y: (bounds.height + plusWidth)/2));
        }
        
        
        UIColor.whiteColor().setStroke();
        plusPath.stroke();
        
        layer.shadowOpacity = 0.7;
        layer.shadowOffset = CGSize(width: 1, height: 3)
    }

}
