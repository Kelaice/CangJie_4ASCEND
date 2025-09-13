package FourASCEND

import std.random.Random

public class nc {
    
    //生成一个零数组
    static func zeros(row_size :Int64)
    :Array<Int64> {
        return Array<Int64>(row_size,{_=>0})
    }

    static func zeros(row_size :Int64, col_size :Int64)
    :Array<Array<Int64>> {
        return Array<Array<Int64>>(row_size,
                            {_=>Array<Int64>(col_size,{_=>0})})
    }   

    //在给定数组中查找是否有给定元素
    static func any(array :Array<Int64>, val :Int64)
    :Bool {
        var b :Bool = false
        for(i in 0..array.size) {
            if(array[i]==val) {
                b = true
            }
        }
        return b
    }
    static func any(array :Array<Array<Int64>>, val :Int64)
    :Bool {
        var b :Bool = false
        for(y in 0..array.size) {
            for(x in 0..array[0].size) {
                if(array[x][y]==val) {
                    b = true
                }
            }
        }
        return b
    }

    //对数组元素求和
    static func sum(array :Array<Int64>)
    :Int64{
        var sum :Int64= 0
        for(i in array) {
            sum += i
        }
        return sum
    }
    static func sum(array :Array<Array<Int64>>)
    :Int64{
        var sum :Int64= 0
        for(y in 0..array.size) {
            for(x in 0..array[0].size)
            {
                sum += array[x][y]
            }
        }
        return sum
    }

    //用给定元素填充数组
    static func fill(array :Array<Int64>, val :Int64)
    :Unit{
        array.fill(val)
    }
    static func fill(array :Array<Array<Int64>>, val :Int64)
    :Unit {
        array.fill(Array<Int64>(array[0].size,{_=>val}))
    }

    //生成随机数组
    static func random_choice(len :Int64, size :Int64, replace !:Bool)
    :Array<Byte>{
        var r :Random = Random()
        var selected :Array<Byte> = Array()
        //生成有重复元素的数组
        if(replace) {
            selected = r.nextBytes(Int32(size))
            selected = selected.map({val =>
                                    let factor :Float16= Float16(len)/256.0
                                    UInt8(Float16(val)*factor)        
                                    })
            return selected
        }
        //通过洗牌算法生成不重复的数组
        else {
            selected = Array<Byte>(len,{i=>UInt8(i)})
            var m = selected.size
            for(i in m-1..-1:-1) {
                var j = r.nextInt64(i)
                selected.swap(i,j)
            }
            return selected[0..size]
        }
    }
}