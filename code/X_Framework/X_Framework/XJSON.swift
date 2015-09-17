//
//  XJSON.swift
//  xlib
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation


//JSON解析器
enum XJSON
{
    case Num(NSNumber)                          //numbern
    case Str(NSString)                          //string
    case Arr([XJSON])                      //array
    case Dic(Dictionary<String, XJSON>)    //dictionary
    case Null(NSError?)                         //error
    
    //构造器（根据json原数据创建XJSON)
    init(data:NSData)
    {
        if let jsonData:AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
        {
            self = XJSON(jsonObject: jsonData);
        }
        else
        {
            self = XJSON.Null(nil);
        }
    }
    
    //构造器（根据初步解析数据创建XJSON
    init(jsonObject data:AnyObject)
    {
        switch data
        {
        case let num as NSNumber:
            self = .Num(num);
        case let str as NSString:
            self = .Str(str);
        case let arr as NSArray:
            var XJSONArr = [XJSON]();
            for obj:AnyObject in arr{
                XJSONArr.append(XJSON(jsonObject: obj));
            }
            self = .Arr(XJSONArr);
        case let dic as NSDictionary:
            var XJSONDic = Dictionary<String, XJSON>();
            for obj in dic{
                if let key = obj.key as? String
                {
                    XJSONDic[key] = XJSON(jsonObject: obj.value);
                }
            }
            self = .Dic(XJSONDic);
        default:
            self = XJSON.Null(nil);
        }
    }
}

//扩展下标
extension XJSON
{
    
    //.Arr类型支持int下标
    subscript(index:Int) -> XJSON{
        get{
            switch self
            {
            case .Arr(let arr) where arr.count < index && arr.count > -1:
                return arr[index];
            default:
                return .Null(NSError(domain: "i am not XJSON.Arr", code: 0, userInfo: nil));
            }
        }
    }
    
    //.Dic类型支持string下标
    subscript(key:String) -> XJSON{
        get{
            switch self
            {
            case .Dic(let dic) where dic[key] != nil:
                return dic[key]!;
            default:
                return .Null(NSError(domain: "i am not XJSON.Dic", code: 0, userInfo: nil));
            }
        }
    }
}

//扩展取值
extension XJSON
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
    var arrayValue:Array<XJSON>?{
        switch self
        {
        case .Arr(let arr):
            return arr;
        default:
            return nil;
        }
    }
    
    //字典类型的数据
    var dictionaryValue:Dictionary<String, XJSON>?{
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
extension XJSON:BooleanType
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

//最低级的XJSON
extension XJSON
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
//extension XJSON: Comparable{
//    private var type:Int{
//        switch self
//        {
//        case XJSON.Num:
//            return 1;
//        case XJSON.Str:
//            return 2;
//        case XJSON.Arr:
//            return 3;
//        case XJSON.Dic:
//            return 4;
//        case XJSON.Null:
//            return 0;
//        default:
//            return -1;
//        }
//    }
//}


//打印相关
extension XJSON: CustomStringConvertible
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
