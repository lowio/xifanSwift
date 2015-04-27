//
//  Level.swift
//  UberJump
//
//  Created by 叶贤辉 on 15/4/23.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

/**
*  game level
*/
struct Level {
    
    init(configFileName:String)
    {
        self.loadConfig(configFileName);
    }
    
    //加载配置文件
    func loadConfig(fileName:String)
    {
        if let plistPath = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist"), let plistData = NSDictionary(contentsOfFile: plistPath)
        {
            if let platforms = plistData["Platforms"] as? NSDictionary
            {
                parseData(platforms){
                    println($0)
                }
            }
            
            if let starts = plistData["Stars"] as? NSDictionary
            {
                parseData(starts){
                    println($0)
                }
            }
        }
    }
    
    
    /**
    解析数据
    
    :param: source   数据源
    :param: repeatHandler 回调函数
    */
    private func parseData(source:NSDictionary, repeatHandler: (nodeData:NodeData) -> ())
    {
        let patternTemplates = source["Patterns"] as! NSDictionary;  //图形模版列表
        let patternInfos = source["Positions"] as! [NSDictionary];    //图形信息列表
        
        for info in patternInfos
        {
            let patternx = info["x"]?.floatValue;
            let patterny = info["y"]?.floatValue;
            let patternName = info["pattern"] as! NSString;
            
            if let patternTemplate = patternTemplates[patternName] as? [NSDictionary]
            {
                for part in patternTemplate
                {
                    let partx = part["x"]?.floatValue;
                    let party = part["y"]?.floatValue;
                    let partType = part["type"]?.integerValue;
                    
                    
                    let position = CGPoint(x: CGFloat(partx! + patternx!), y: CGFloat(party! + patterny!));
                    let nodeData = NodeData(position: position, type: Int(partType!));
                    
                    repeatHandler(nodeData: nodeData);
                }
            }
        }
    }
}


//node 数据
struct NodeData:Printable {
    
    //位置
    var position:CGPoint;
    
    //类型
    var type:Int;
    
    
    var description:String {
        return "type:\(type), position:\(position)";
    }
}