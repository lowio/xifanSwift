//
//  JSONParser.swift
//  JSONParser
//
//  Created by 叶贤辉 on 15/3/20.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation


//JSON解析器
enum JSONParser
{
    case Num(NSNumber)                          //numbern
    case Str(NSString)                          //string
    case Arr([JSONParser])                      //array
    case Dic(Dictionary<String, JSONParser>)    //dictionary
    case Null(NSError?)                         //error
    
    //构造器（根据json原数据创建JSONParser)
    init(data:NSData)
    {
        if let jsonData:AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
        {
            self = JSONParser(jsonObject: jsonData);
        }
        else
        {
            self = JSONParser.Null(nil);
        }
    }
    
    //构造器（根据初步解析数据创建JSONParser
    init(jsonObject data:AnyObject)
    {
        switch data
        {
        case let num as NSNumber:
            self = .Num(num);
        case let str as NSString:
            self = .Str(str);
        case let arr as NSArray:
            var jsonParserArr = [JSONParser]();
            for obj:AnyObject in arr{
                jsonParserArr.append(JSONParser(jsonObject: obj));
            }
            self = .Arr(jsonParserArr);
        case let dic as NSDictionary:
            var jsonParserDic = Dictionary<String, JSONParser>();
            for obj in dic{
                if let key = obj.key as? String
                {
                    jsonParserDic[key] = JSONParser(jsonObject: obj.value);
                }
            }
            self = .Dic(jsonParserDic);
        default:
            self = JSONParser.Null(nil);
        }
    }
}

//扩展下标
extension JSONParser
{
    
    //.Arr类型支持int下标
    subscript(index:Int) -> JSONParser{
        get{
            switch self
            {
            case .Arr(let arr) where arr.count < index && arr.count > -1:
                return arr[index];
            default:
                return .Null(NSError(domain: "i am not JSONParser.Arr", code: 0, userInfo: nil));
            }
        }
    }
    
    //.Dic类型支持string下标
    subscript(key:String) -> JSONParser{
        get{
            switch self
            {
            case .Dic(let dic) where dic[key] != nil:
                return dic[key]!;
            default:
                return .Null(NSError(domain: "i am not JSONParser.Dic", code: 0, userInfo: nil));
            }
        }
    }
}

//扩展取值
extension JSONParser
{
    //获取原始数据 需要自己转换
    var originalValue:Any?{
        switch self
        {
        case .Num(let num):
            return num;
        case .Str(let str):
            return str;
        case .Arr(let arr):
            return arr;
        case .Dic(let dic):
            return dic;
        default:
            return nil
        }
    }
    
    //数组类型的数据
    var arrayValue:Array<JSONParser>?{
        switch self
        {
        case .Arr(let arr):
            return arr;
        default:
            return nil;
        }
    }
    
    //字典类型的数据
    var dictionaryValue:Dictionary<String, JSONParser>?{
        switch self
        {
        case .Dic(let dic):
            return dic;
        default:
            return nil;
        }
    }
}

//用于判断是否能被当成bool类型判断
extension JSONParser:BooleanType
{
    var boolValue:Bool{
        switch self{
        case .Num(let num):
            return num.boolValue;
        case .Str(let str):
            return str.boolValue;
        case .Arr(let arr):
            return !arr.isEmpty;
        case .Dic(let dic):
            return !dic.isEmpty;
        default:
            return false;
        }
    }
}

//最低级的jsonparser
extension JSONParser
{
    //字符串
    var stringValue:String?{
        switch self{
        case .Num(let num):
            return num.stringValue;
        case .Str(let str):
            return str as String
        default:
            return nil;
        }
    }
    
    //nsnumber
    var numberValue:NSNumber?{
        switch self{
        case .Num(let num):
            return num;
        case .Str(let str):
            let num = NSScanner(string: str as String)
            if num.scanDouble(nil) && num.atEnd
            {
                return NSNumber(double: (str as NSString).doubleValue)
            }
            return nil
        default:
            return nil;
        }
    }
    
    //浮点
    var floatValue:Float?{
        return numberValue?.floatValue;
    }
    
    //int
    var intValue:Int?{
        return numberValue?.longValue;
    }
    
    //double
    var doubleValue:Double?{
        return numberValue?.doubleValue;
    }
}

//比较相关 比较麻烦暂时忽略 可以外部扩展
//extension JSONParser: Comparable{
//    private var type:Int{
//        switch self
//        {
//        case JSONParser.Num:
//            return 1;
//        case JSONParser.Str:
//            return 2;
//        case JSONParser.Arr:
//            return 3;
//        case JSONParser.Dic:
//            return 4;
//        case JSONParser.Null:
//            return 0;
//        default:
//            return -1;
//        }
//    }
//}


//打印相关
extension JSONParser: CustomStringConvertible
{
    var description: String {
        switch self{
        case .Num(let num):
            return num.description;
        case .Str(let str):
            return str.description;
        case .Arr(let arr):
            return arr.description;
        case .Dic(let dic):
            return dic.description;
        default:
            return "null"
        }
    }
}
