package ohos_app_cangjie_entry.game_body

import std.collection.*
import std.math.*

type Board = (Array<Array<Int64>>,
                Array<Array<Int64>>,
                Array<Array<Int64>>,
                Int64,
                Int64,
                Int64)

public class FourAscendGame{

    let board_size :Int64
    let max_hp1 :Int64
    let max_hp2 :Int64
    var hp1 :Int64
    var hp2 :Int64
    var plant_timer :Int64
    var grid_count :Int64

    public init(board_size :Int64, hp1: Int64, hp2 :Int64){
        this.board_size = board_size
        this.max_hp1 = hp1
        this.max_hp2 = hp2
        this.hp1 = hp1
        this.hp2 = hp2
        this.plant_timer = 0
        this.grid_count = this.board_size * this.board_size
    }

        
    /*
    获取初始棋盘状态
    返回: (棋子矩阵, 魔法植物矩阵, 升华状态矩阵, 玩家1血量, 玩家2血量, 植物计时器)
    */
    public func getInitBoard()
    :Board {
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

    /*
    获取当前玩家所有合法落子位置
    返回: 一维数组，1表示可落子，0表示不可落子
    */
    //暂无实际用途
    public func getValidMoves(pieces :Array<Array<Int64>>, hp1 :Int64, hp2 :Int64, player :Int64) {
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

    /*
    根据玩家行动，返回下一步棋盘状态和下一个玩家
    action: 落子编号（0~80）
    */
    public func getNextState(board :Board, player :Int64, action :Int64
        ) {
        var pieces = board[0]
        var magic_plants = board[1]
        var ascend_state = board[2]
        var hp1 = board[3]
        var hp2 = board[4]
        var plant_timer = board[5]

        var pieces_copy = pieces.clone()
        var magic_plants_copy = magic_plants.clone()
        var ascend_state_copy = ascend_state.clone()

        let row = action / this.board_size
        let col = action % this.board_size
        pieces_copy[row][col] = player

        var is_defence_turn :Bool = nc.any(ascend_state_copy,1) || nc.any(ascend_state_copy,-1)
        //防御阶段
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
            //计算所有升华棋子的总攻击力
            for(y in 0..ascend_state_copy.size) {
                for(x in 0..ascend_state_copy[0].size) {
                    if(ascend_state_copy[x][y] != 0) {
                        attack_power += 1 +magic_plants_copy[x][y]
                    }
                }
            }
            var damage = abs(attack_power-defence_power)

            //结算血量
            if(attack_power > defence_power) {
                if(player == 1) {
                    hp1 -= damage
                }
                else {
                    hp2 -= damage
                }
            }
            else if(attack_power < defence_power) {
                if(player == 1) {
                    hp2 -= damage
                }
                else {
                    hp1 -= damage
                }
            }
            //更新血量
            hp1 = max(0,hp1)
            hp2 = max(0,hp2)
            //重置升华棋子处的魔法植物
            for(y in 0..ascend_state_copy.size) {
                for(x in 0..ascend_state_copy[0].size) {
                    if(ascend_state_copy[x][y] != 0) {
                        magic_plants_copy[x][y] = 0
                    }
                }
            }
            nc.fill(ascend_state_copy,0)
        }
        //攻击阶段
        else {
            ascend(
                pieces_copy,
                magic_plants_copy,
                ascend_state_copy,
                row,
                col,
                player,
                true
            )
        }
        //魔法植物计时器
        plant_timer += 1
        if(plant_timer > 6) {
            spawn_magic_plants(pieces_copy, magic_plants_copy, 2)
            plant_timer = 0
        }
        //返回最新棋盘状态和血量
        return (pieces_copy, magic_plants_copy, ascend_state_copy, hp1, hp2, plant_timer)
    }

    /*
    判断游戏是否结束，返回胜负结果
    -999 - 未结束
    1    - 玩家1胜
    -1   - 玩家2胜
    0    - 平局
    */
    public func getGameEnded(board :Board) {
        var pieces = board[0]
        var hp1 = board[3]
        var hp2 = board[4]

        if(hp1 <= 0 && hp2 <= 0) {
            return 0
        }
        else if(hp1 <= 0){
            return -1
        }
        else if(hp2 <= 0) {
            return 1
        }
        if(!nc.any(pieces,0)) {
            if(hp1 > hp2) {
                return 1
            }
            else if(hp2 > hp1) {
                return -1
            }
            else {
                return 0
            }
        }
        //未结束
        return -999
    }

    /*
    计算升华状态相关数据
    */
    public func ascend(
        pieces :Array<Array<Int64>>,
        magic_plants :Array<Array<Int64>>,
        ascend_state :Array<Array<                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Int64>>,
        row :Int64,
        col :Int64,
        player :Int64,
        set_ascend_value :Bool
        ) {
            var total_power = 0
            var suc_connextion = false
            let directions = [[0,1],[1,0],[1,1],[1,-1]]
            //计算是否连线
            for(i in directions) {
                var dx = i[0]
                var dy = i[1]
                var connected_pos :ArrayList<Array<Int64>> = ArrayList()
                var r = 0
                var c = 0 
                var power = 0

                r = row +dx
                c = col +dy
                while((0<=r && r<this.board_size) && (0<=c && c<this.board_size) && pieces[r][c] == player) {
                    connected_pos.append([r,c])
                    r = r +dx
                    c = c +dy
                }

                r = row -dx
                c = col -dy
                while((0<=r && r<this.board_size) && (0<=c && c<this.board_size) && pieces[r][c]== player) {
                    connected_pos.append([r,c])
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
                            if(set_ascend_value)    {ascend_state[r][c] = player}
                            else                    {ascend_state[r][c] = 0}
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
                if(set_ascend_value)    {ascend_state[row][col] = player}
                else                    {ascend_state[row][col] = 0}
                if(!set_ascend_value) {
                    magic_plants[row][col] = 0
                }
            }

            return total_power
    }

    /*
    在棋盘上随机生成魔法植物
    count: 生成数量
    */
    public func spawn_magic_plants(pieces :Array<Array<Int64>>, magic_plants :Array<Array<Int64>>, count :Int64) {
        //查找可以生成魔法植物的位置
        var empty_indices :ArrayList<Array<Int64>> = ArrayList()
        for(y in 0..9) {
            for(x in 0..9) {
                if(pieces[x][y]==0 && magic_plants[x][y]<2) {
                    empty_indices.append([x,y])
                }
            }
        }
        //在随机位置生成魔法植物
        if(empty_indices.size >= count) {
            var selected_idx = nc.random_choice(empty_indices.size,
                                                count,
                                                replace: false)
            for(idx in selected_idx) {
                var x = empty_indices[Int64(idx)][0]
                var y = empty_indices[Int64(idx)][1]
                magic_plants[x][y] += 1
            }
        }
    }
}


public class StupidFourAscendPlayer{
    var game :FourAscendGame
    var directions :Array<Array<Int64>>
    public init(game : FourAscendGame)
    {
        this.game = game
        this.directions = [[0,1],[1,0],[1,1],[1,-1]]
    }

    public func getValidAction(valid :Array<Int64>)
    {
        var temp = 0
        var valid_actions = Array<Int64>(80,{_=>0})
        for(i in 0..81)
        {
            if (valid[i] == 1)
            {
                valid_actions[temp] = i
                temp += 1
            }
        }

        return valid_actions[0..temp]
    }


    public func play(board :Board)
    {
        var pieces = board[0]
        var magic_plants = board[1]
        var ascend_state = board[2]
        var hp1 = board[3]
        var hp2 = board[4]
        var plant_timer = board[5]
        var valid = this.game.getValidMoves(board[0], board[3], board[4], -1)
        var valid_action =getValidAction(valid)
        if (valid_action == [])
        {

        }
    }

    public func _choose_defence_move(board :Board, valid_actions :Array<Int64>)
    {
        var player = -1
        var pieces = board[0]
        var magic_plants = board[1]
        var ascend_state = board[2]
        var hp1 = board[3]
        var hp2 = board[4]
        var plant_timer = board[5]
        var opponent_player = -player
        var original_opponent_power = nc.sum(ascend_state)// + nc.sum(magic_plants)缺少魔法植物结算
        var candidate = Array<Int64>()
        for (action in valid_actions)
        {
            var row = action / this.game.board_size
            var col = action % this.game.board_size
            var test_pieces = pieces.clone()
            var test_magic_plants = magic_plants.clone()
            var test_ascend_state = ascend_state.clone()
            var can_remove_opponent_piece = ascend_state[row][col] == opponent_player
            var reduced_opponent_power = 0
            if (can_remove_opponent_piece)
            {
                test_ascend_state[row][col] = 0//原文是false
                reduced_opponent_power = nc.sum(test_ascend_state) //+ np.sum(magic_plants[test_ascend_state]
            }
            else
            {
                reduced_opponent_power = original_opponent_power
            }
            test_pieces[row][col] = player
            
        }
    }
}