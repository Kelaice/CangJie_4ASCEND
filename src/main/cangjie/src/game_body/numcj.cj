package ohos_app_cangjie_entry.game_body

import std.random.Random
import ohos.component.Row

public class nc {

    //生成一个零数组
    public static func zeros(row_size: Int64): Array<Int64> {
        return Array<Int64>(row_size, {_ => 0})
    }

    public static func zeros(row_size: Int64, col_size: Int64): Array<Array<Int64>> {
        return Array<Array<Int64>>(row_size, {_ => Array<Int64>(col_size, {_ => 0})})
    }

    //在给定数组中查找是否有给定元素
    public static func any(array: Array<Int64>, val: Int64): Bool {
        var b: Bool = false
        for (i in 0..array.size) {
            if (array[i] == val) {
                b = true
            }
        }
        return b
    }
    public static func any(array: Array<Array<Int64>>, val: Int64): Bool {
        var b: Bool = false
        for (row in 0..array.size) {
            for (col in 0..array[0].size) {
                if (array[row][col] == val) {
                    b = true
                }
            }
        }
        return b
    }

    //对数组元素求和
    public static func sum(array: Array<Int64>): Int64 {
        var sum: Int64 = 0
        for (i in array) {
            sum += i
        }
        return sum
    }
    public static func sum(array: Array<Array<Int64>>): Int64 {
        var sum: Int64 = 0
        for (row in 0..array.size) {
            for (col in 0..array[0].size) {
                sum += array[row][col]
            }
        }
        return sum
    }

    //用给定元素填充数组
    public static func fill(array: Array<Int64>, val: Int64): Unit {
        //        array.fill(val)
        for (i in 0..array.size) {
            array[i] = val
        }
    }
    public static func fill(array: Array<Array<Int64>>, val: Int64): Unit {
        //        array.fill(Array<Int64>(array[0].size,{_=>val}))
        for (row in 0..array.size) {
            for (col in 0..array[0].size) {
                array[row][col] = val
            }
        }
    }

    //深拷贝数组
    static func copy(array: Array<Int64>): Array<Int64> {
        var copy = Array<Int64>(array.size, {_ => 0})
        for (i in 0..array.size) {
            copy[i] = array[i]
        }
        return copy
    }
    static func copy(array: Array<Array<Int64>>): Array<Array<Int64>> {
        var copy = Array<Array<Int64>>(array.size, {_ => Array<Int64>(array[0].size, {_ => 0})})
        for (row in 0..array.size) {
            for (col in 0..array[0].size) {
                copy[row][col] = array[row][col]
            }
        }
        return copy
    }

    //生成随机数组
    public static func random_choice(len: Int64, size: Int64, replace!: Bool): Array<Byte> {
        var r: Random = Random()
        var selected: Array<Byte> = Array(len, {_ => 0})
        //生成有重复元素的数组
        if (replace) {
            //            selected = r.nextBytes(Int32(size))
            selected = r.nextUInt8s(selected)
            //            selected = selected.map({val =>
            //                                    let factor :Float16= Float16(len)/256.0
            //                                    UInt8(Float16(val)*factor)
            //                                    })
            var factor: Float64 = Float64(len) / 256.0
            for (i in 0..len) {
                selected[i] = UInt8(Float64(selected[i]) * factor)
            }

            return selected
        }
            //通过洗牌算法生成不重复的数组
            else {
            selected = Array<Byte>(len, {i => UInt8(i)})
            var m = selected.size
            for (i in m - 1..0 : -1) {
                var j = r.nextInt64(i)
                //                selected.swap(i,j)
                var temp = selected[j]
                selected[j] = selected[i]
                selected[i] = temp
            }
            return selected[0..size]
        }
    }

    //将一维数组折叠为二维
    public static func fold(oneD: Array<Int64>, row: Int64, col: Int64): Array<Array<Int64>> {
        var res: Array<Array<Int64>> = Array<Array<Int64>>(row, {_ => Array<Int64>(col, {_ => 0})})

        for (i in 0..row) {
            for (j in 0..col) {
                res[i][j] = oneD[i * row + j]
            }
        }

        return res
    }

    //将二维数组展开为一维
    public static func flatten(twoD: Array<Array<Int64>>, len: Int64): Array<Int64> {
        var res: Array<Int64> = Array(len, {_ => 0})
        var row = twoD.size
        var col = twoD[0].size
        for (i in 0..row) {
            for (j in 0..col) {
                res[i * row + j] = twoD[i][j]
            }
        }
        return res
    }
}
