//
//  ViewController.swift
//  FLO
//
//  Created by 叶贤辉 on 15/3/31.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //graphView 是否显示
    var isGraphViewShowing = false;

    @IBOutlet weak var counterLable: UILabel!;
    
    @IBOutlet weak var counterView: CounterView!;
    
    @IBOutlet weak var grapView:GraphView!;
    
    @IBOutlet weak var containerView:UIView!;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        counterLable.text = String(counterView.counter);
//        containerViewTap(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClick(button:PushButtonView)
    {
        var counter = counterView.counter;
        if button.isAddButton
        {
            counter++;
        }
        else if counterView.counter > 0
        {
            counter--;
        }
        
        if counter <= maxCount
        {
            counterView.counter = counter;
            counterLable.text = String(counterView.counter);
        }
    }
    
    
    @IBAction func containerViewTap(gesture:UITapGestureRecognizer?)
    {
        if isGraphViewShowing
        {
            UIView.transitionFromView(grapView, toView: counterView, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft|UIViewAnimationOptions.ShowHideTransitionViews, completion: nil);
        }
        else
        {
            UIView.transitionFromView(counterView, toView: grapView, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight|UIViewAnimationOptions.ShowHideTransitionViews, completion: nil);
        }
        isGraphViewShowing = !isGraphViewShowing;
    }
}

