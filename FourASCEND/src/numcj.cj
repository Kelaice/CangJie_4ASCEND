package FourASCEND

import std.collection.*

public class nc {
    static func zeros(row_size :Int64)
    :Array<Int64> {
        return Array<Int64>(row_size,{_=>0})
    }

    static func zeros(row_size :Int64, col_size :Int64)
    :Array<Array<Int64>> {
        return Array<Array<Int64>>(row_size,
                            {_=>Array<Int64>(col_size,{_=>0})})
    }

    static func copy(array :Array<Int64>) 
    :Array<Int64> {
        var temp = Array<Int64>(array.size,{_=>0})
        for(i in 0..array.size) {
            temp[i] = array[i]
        }
        return temp
    }
    static func copy(array :Array<Array<Int64>>) 
    :Array<Array<Int64>> {
        var temp = Array<Array<Int64>>(array.size,
                            {_=>Array<Int64>(array[0].size,{_=>0})})
        for(y in 0..array.size) {
            for(x in 0..array[0].size) {
                temp[x][y] = array[x][y]
            }
        }
        return temp
    }

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

    static func sum(array :Array<Int64>) {
        var sum :Int64= 0
        for(i in array) {
            sum += i
        }
        return sum
    }
    static func sum(array :Array<Array<Int64>>) {
        var sum :Int64= 0
        for(y in 0..array.size) {
            for(x in 0..array[0].size)
            {
                sum += array[x][y]
            }
        }
        return sum
    }
}