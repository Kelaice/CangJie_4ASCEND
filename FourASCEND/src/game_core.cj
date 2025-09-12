package FourASCEND

import std.collection.*
import std.math.*

public class FourAscendGame{

    let board_size :Int64
    let max_hp1 :Int64
    let max_hp2 :Int64
    var hp1 :Int64
    var hp2 :Int64
    var plant_timer :Int64
    var grid_count :Int64

    public init(board_size :Int64, hp1: Int64, hp2 :Int64) {
        this.board_size = board_size
        this.max_hp1 = 6
        this.max_hp2 = 6
        this.hp1 = this.max_hp1
        this.hp2 = this.max_hp2
        this.plant_timer = 0
        this.grid_count = this.board_size * this.board_size
    }

    func getInitBoard() {
        """
        获取初始棋盘状态
        返回: (棋子矩阵, 魔法植物矩阵, 升华状态矩阵, 玩家1血量, 玩家2血量, 植物计时器)
        """
        var pieces = nc.zeros(board_size,board_size)
        var magic_plants = nc.zeros(board_size,board_size)
        var ascend_state = nc.zeros(board_size,board_size)

        return (
            pieces,
            magic_plants,
            ascend_state,
            this.hp1,
            this.hp2,
            this.plant_timer
        )
    }

    func getValidMoves(pieces :Array<Array<Int64>>, hp1 :Int64, hp2 :Int64, player :Int64) {
        """
        获取当前玩家所有合法落子位置
        返回: 一维数组，1表示可落子，0表示不可落子
        """
        if((player==1 && hp1<=0)||(player==-1 && hp2<=0)) {
            return nc.zeros(this.grid_count)
        }

        var valid = nc.zeros(81)
        for(x in 0..this.board_size) {
            for(y in 0..this.board_size) {
                if(pieces[x][y]==0) {
                    valid[x*this.board_size +y] = 1
                }
                else {
                    valid[x*this.board_size +y] = 0
                }
            }
        }
        return valid
    }

    func getNextState(
        pieces :Array<Array<Int64>>,
        magic_plants :Array<Array<Int64>>,
        ascend_state :Array<Array<Int64>>,
        hp1:Int64,
        hp2 :Int64,
        player :Int64,
        action :Int64
        ) {
        """
        根据玩家行动，返回下一步棋盘状态和下一个玩家
        action: 落子编号（0~80）
        """
        var pieces_copy = nc.copy(pieces)
        var magic_plants_copy = nc.copy(magic_plants)
        var ascend_state_copy = nc.copy(ascend_state)

        let row = action / this.board_size
        let col = action % this.board_size
        pieces_copy[row][col] = player

        var is_defence_turn :Bool = nc.any(ascend_state_copy,1)

        if(is_defence_turn) {
            var defence_power = ascend(
                pieces_copy,
                magic_plants_copy,
                ascend_state_copy,
                row,
                col,
                player,
                false
            )
            ascend_state_copy[row][col] = 0
            var attack_power = 0
            for(y in 0..ascend_state_copy.size) {
                for(x in 0..ascend_state_copy[0].size) {
                    if(ascend_state_copy[x][y]==1) {
                        attack_power += 1 +magic_plants_copy[x][y]
                    }
                }
            }
            var damage = abs(attack_power-defence_power)

            //结算血量
            if(attack_power > defence_power) {
                if(player==1) {
                    hp1 -= damage
                }
            }
        }
    }

    func ascend(
        pieces :Array<Array<Int64>>,
        magic_plants :Array<Array<Int64>>,
        ascend_state :Array<Array<Int64>>,
        row :Int64,
        col :Int64,
        player :Int64,
        set_ascend_value :Bool
        ) {
            var total_power = 0
            var suc_connextion = false
            let directions = [[0,1],[1,0],[1,1],[1,-1]]

            for(i in directions) {
                var dx = i[0]
                var dy = i[1]
                var connected_pos :ArrayList<Array<Int64>> = ArrayList()
                var r = 0
                var c = 0 
                var power = 0

                r = row +dx
                c = col +dy
                while((0<=r && r<this.board_size) && (0<=c && c<this.board_size) && pieces[r][c]==player) {
                    connected_pos.add([r,c])
                    r = r +dx
                    c = c +dy
                }

                r = row -dx
                c = col -dy
                while((0<=r && r<this.board_size) && (0<=c && c<this.board_size) && pieces[r][c]==player) {
                    connected_pos.add([r,c])
                    r = r -dx
                    c = c -dy
                }

                power = connected_pos.size
                if(power >= 3) {
                    var magic_bonus = 0
                    for(pos in connected_pos) {
                        magic_bonus += magic_plants[pos[0]][pos[1]]
                    }
                    suc_connextion = true
                    total_power += power + magic_bonus

                    for(i in connected_pos) {
                        r = i[0]
                        c = i[1]
                        if(r!=row || c != col) {
                            pieces[r][c] = 0
                            if(set_ascend_value)    {ascend_state[r][c]=1}
                            else                    {ascend_state[r][c]=0}
                            if(!set_ascend_value) {
                                magic_plants[r][c] = 0
                            }
                        }
                    }
                }
            }

            if(suc_connextion)  {
                total_power += 1 + magic_plants[row][col]
                pieces[row][col] = 0
                if(set_ascend_value)    {ascend_state[row][col]=1}
                else                    {ascend_state[row][col]=0}
                if(!set_ascend_value) {
                    magic_plants[row][col] = 0
                }
            }

            return total_power
        }
}