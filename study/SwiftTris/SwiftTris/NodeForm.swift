import Foundation

class NodeForm {
    
    //行列
    var column, row:Int
    //颜色
    var color:NodeColor
    //定向
    var orientation:NodeOrientation
    
    //node列表
    var nodeList = Array<Node>()
    
    //获取不同方向的node节点的相对坐标（子类重写)
    var posOfOrientation:[NodeOrientation:[(c:Int, r:Int)]]{
        return [:]
    }
    
    //底部的node 用于检测落点
    var bottomNodes:[Int:Node]?
    
    init(column:Int, row:Int, color:NodeColor, orientation:NodeOrientation)
    {
        self.column = column
        self.row = row
        self.color = color
        self.orientation = orientation
        initNodeList()
        updateBottmNodes()
    }
    
    convenience init(column:Int, row:Int)
    {
        self.init(column: column, row: row, color: NodeColor.getRandomColor(), orientation: NodeOrientation.getRandomOrientation())
    }
    
    //初始化nodelist
    func initNodeList()
    {
        if let pList = posOfOrientation[orientation]
        {
            for p in pList
            {
                let n = Node(column: column + p.c, row: row + p.r, color: color)
                self.nodeList.append(n)
            }
        }
    }
    
    //更新底部node列表
    func updateBottmNodes()
    {
        bottomNodes = [:]
        for n in nodeList{
            if let oldn = bottomNodes![n.column]
            {
                if n.row > oldn.row
                {
                    bottomNodes![n.column] = n
                }
            }
            else
            {
                bottomNodes![n.column] = n
            }
        }
    }
    
    //旋转方向
    func rotate(clockwise:Bool)
    {
        orientation.rotate(clockwise)
        updatePosition()
        updateBottmNodes()
    }
    
    //更新行和列
    func updatePosition()
    {
        if let offset = posOfOrientation[orientation]
        {
            for (i, nf) in enumerate(nodeList)
            {
                nf.column = self.column + offset[i].c
                nf.row = self.row + offset[i].r
            }
        }
    }
    
    //移动到指定行列
    func move(toColumn:Int, toRow:Int)
    {
        self.column = toColumn
        self.row = toRow
        updatePosition()
    }
    
    //偏移到某位置
    func move(fixColumn:Int, fixRow:Int)
    {
        self.column += fixColumn
        self.row += fixRow
        updatePosition()
    }
    
    func up()
    {
        move(0, fixRow: -1)
    }
    
    func down()
    {
        move(0, fixRow: 1)
    }
    
    func left()
    {
        move(-1, fixRow: 0)
    }
    
    func right()
    {
        move(1, fixRow: 0)
    }
}

//定向
enum NodeOrientation:Int, Printable
{
    case Zero = 0, Nighty = 90, OneEighty = 180, TwoSeventy = 270
    
    //协议实现
    var description:String{
        return String(self.rawValue)
    }
    

    //旋转方向（变异方法)
    mutating func rotate(clockwise:Bool)
    {
        let newValue = self.rawValue + (clockwise ? 90 : -90)
        if newValue > NodeOrientation.TwoSeventy.rawValue
        {
            self = NodeOrientation.Zero
        }
        else if newValue < NodeOrientation.Zero.rawValue
        {
            self = NodeOrientation.TwoSeventy
        }
        else
        {
            self = NodeOrientation(rawValue: newValue)!
        }
    }
    
    //获取随即方向
    static func getRandomOrientation() -> NodeOrientation
    {
        let orientationKinds:UInt32 = 4
        return NodeOrientation(rawValue: Int(arc4random_uniform(orientationKinds)) * 90)!
    }
}

//形状
enum NodeFormEnum:Int, Printable
{
    case Square = 0, T, L, J, Z, S, Line
    
    var description:String{
        switch self{
        case .Square:
            return "正方形"
        case .T:
            return "T形"
        case .L:
                return "L形"
        case .J:
            return "J形"
        case .Z:
            return "Z形"
        case .S:
            return "S形"
        case .Line:
            return "L形"
        }
    }
    
    func getNodeForm(column:Int, row:Int) -> NodeForm
    {
        switch self
        {
        case .Square:
            return SquareForm(column: column, row: row)
        case .T:
            return TForm( column: column, row: row)
        case .L:
            return LForm( column: column, row: row)
        case .J:
            return JForm( column: column, row: row)
        case .Z:
            return ZForm( column: column, row: row)
        case .S:
            return SForm( column: column, row: row)
        case .Line:
            return LineForm(column: column, row: row)
        }
    }
    
    //获取随机形状 随机颜色 的形状
    static func getRandomForm(column:Int, row:Int) -> NodeForm
    {
        let formKinds:UInt32 = 7
        let nf = NodeFormEnum(rawValue: Int(arc4random_uniform(formKinds)))
        return nf!.getNodeForm(column, row: row)
    }
    
}
