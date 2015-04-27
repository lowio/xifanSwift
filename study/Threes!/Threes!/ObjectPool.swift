//
//  ObjectPool.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/25.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//==============ObjectPool对象池==============
class ObjectPool<ObjectType:Hashable>{
    
    init()
    {
        pools = [:]
    }
    
    //池子
    private var pools:Dictionary<String, ObjectPoolStruct<ObjectType>>
    
    //获取key
    private func getKey(object:AnyObject!) -> String
    {
        var key:UnsafePointer<Int8> = object_getClassName(object)
        return String(UTF8String:key)!
    }
    
    //回收
    func recycle(object:AnyObject, max:Int = -1)
    {
        let key = getKey(object)
        var pool = pools[key]
        if pool == nil
        {
            pool = ObjectPoolStruct<ObjectType>(max: max)
        }
        pool!.recycle(object as! ObjectType)
        pools[key] = pool!
    }
    
    //获取对象池中的对象
    func get(key:AnyClass) -> ObjectType?
    {
        if pools.isEmpty
        {
            return nil
        }
        
        let dicKey = getKey(key)
        if let tempPool = pools[dicKey]
        {
            var pool = tempPool
            let object = pool.get()
            pools[dicKey] = pool
            return object
        }
        return nil
    }
}

extension ObjectPool
{
    //获取对象池类型个数
    var count:Int{
        return pools.count
    }
    
    //获取指定类型的对象池中对象的个数
    func getCount(key:AnyClass) -> Int
    {
        let dicKey = getKey(key)
        if let tempPool = pools[dicKey]
        {
            return tempPool.count
        }
        return 0
    }
    
    //清空所有对象池
    func clear()
    {
        for key in pools.keys
        {
            clear(key)
        }
    }
    
    //清空指定类型的对象池
    func clear(key:AnyClass)
    {
        let dicKey = getKey(key)
        clear(dicKey)
    }
    
    private func clear(key:String)
    {
        if let tempPool = pools[key]
        {
            var pool = tempPool
            pool.clear()
            pools[key] = nil
        }
        
    }
}

//============ObjectPoolStruct 对象池 结构体============
private struct ObjectPoolStruct<KeyType:Hashable>
{
    //池子
    private var pool:Dictionary<KeyType, Bool>
    
    //最大存储个数 -1表示无限制
    private var max:Int = -1
    
    init(max:Int)
    {
        self.max = max
        pool = [:]
    }
    
    init()
    {
        self.init(max: -1)
    }
    
    //回收
    mutating func recycle(object:KeyType)
    {
        if pool.count == max
        {
            return
        }
        pool[object] = true
    }
    
    //获取对象池中的对象
    mutating func get() -> KeyType?
    {
        if pool.isEmpty
        {
            return nil
        }
        
        for object in pool.keys
        {
            pool[object] = nil
            return object
        }
        return nil
    }
}

extension ObjectPoolStruct
{
    //对象池中的对象个数
    var count:Int{
        return self.pool.count
    }
    
    //清空对象池
    mutating func clear()
    {
        self.pool.removeAll(keepCapacity: false)
    }
}