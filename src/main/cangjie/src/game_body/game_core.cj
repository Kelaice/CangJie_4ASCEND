package ohos_app_cangjie_entry.game_body

import std.collection.*
import std.math.*
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.sync.*
import ohos.font.*
import std.time.*
import ohos.crypto.Random
import std.collection.ArrayList

type Board = (Array<Array<Int64>>, Array<Array<Int64>>, Array<Array<Int64>>, Int64, Int64, Int64)

public class FourAscendGame {
    let board_size: Int64
    let max_hp1: Int64
    let max_hp2: Int64
    var hp1: Int64
    var hp2: Int64
    var plant_timer: Int64
    var grid_count: Int64

    var pre_hp1: Int64
    var pre_hp2: Int64

    var wp: ObservedArrayList<Array<Int64>>
    var bp: ObservedArrayList<Array<Int64>>

    var animateFlag: Bool
    var unopposed: Bool

    public init(board_size: Int64, hp1: Int64, hp2: Int64) {
        this.board_size = board_size
        this.max_hp1 = hp1
        this.max_hp2 = hp2
        this.hp1 = hp1
        this.hp2 = hp2
        this.plant_timer = 0
        this.grid_count = this.board_size * this.board_size
        this.pre_hp1 = hp1
        this.pre_hp2 = hp2
        this.wp = ObservedArrayList(ArrayList())
        this.bp = ObservedArrayList(ArrayList())
        this.animateFlag = false
        this.unopposed = false
    }

    /*
    获取初始棋盘状态
    返回: (棋子矩阵, 魔法植物矩阵, 升华状态矩阵, 玩家1血量, 玩家2血量, 植物计时器)
     */
    public func getInitBoard(): Board {
        var pieces = nc.zeros(board_size, board_size)
        var magic_plants = nc.zeros(board_size, board_size)
        var ascend_state = nc.zeros(board_size, board_size)

        return (pieces, magic_plants, ascend_state, this.hp1, this.hp2, this.plant_timer)
    }

    /*
    获取当前玩家所有合法落子位置
    返回: 一维数组，1表示可落子，0表示不可落子
     */
    public func getValidMoves(board: Board, player: Int64) {
        var pieces = nc.copy(board[0])
        var hp1 = board[3]
        var hp2 = board[4]

        if ((player == 1 && hp1 <= 0) || (player == -1 && hp2 <= 0)) {
            return nc.zeros(this.grid_count)
        }

        var valid = nc.zeros(81)
        for (x in 0..this.board_size) {
            for (y in 0..this.board_size) {
                if (pieces[x][y] == 0) {
                    valid[x * this.board_size + y] = 1
                } else {
                    valid[x * this.board_size + y] = 0
                }
            }
        }
        return valid
    }

    /*
    根据玩家行动，返回下一步棋盘状态和下一个玩家
    action: 落子编号（0~80）
     */
    public func getNextState(board: Board, player: Int64, action: Int64) {
        var pieces = board[0]
        var magic_plants = board[1]
        var ascend_state = board[2]
        var hp1 = board[3]
        var hp2 = board[4]
        var plant_timer = board[5]

        var pieces_copy = nc.copy(pieces)
        var magic_plants_copy = nc.copy(magic_plants)
        var ascend_state_copy = nc.copy(ascend_state)

        let row = action / this.board_size
        let col = action % this.board_size
        pieces_copy[row][col] = player

        var is_defence_turn: Bool = nc.any(ascend_state_copy, -player)
        //防御阶段
        if (is_defence_turn) {
            ascend_state_copy[row][col] = 0

            var defence_power = ascend(
                pieces_copy,
                magic_plants_copy,
                ascend_state_copy,
                row,
                col,
                player,
                false
            )

            //计算所有升华棋子的总攻击力
            var attack_power = 0
            for (row in 0..ascend_state_copy.size) {
                for (col in 0..ascend_state_copy[0].size) {
                    if (ascend_state_copy[row][col] == -player) {
                        attack_power += 1 + magic_plants_copy[row][col]
                    }
                }
            }
            var damage = abs(attack_power - defence_power)

            //单方面进攻指示器
            if (defence_power == 0) {
                this.unopposed = true
            }
            //清除被占据的升华棋子
            if (player == 1) {
                var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(ArrayList())
                for (i in 0..bp.size) {
                    if (row != bp[i][0] || col != bp[i][1]) {
                        temp.append(bp[i])
                    }
                }
                bp = temp
            } else if (player == -1) {
                var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(ArrayList())
                for (i in 0..wp.size) {
                    if (row != wp[i][0] || col != wp[i][1]) {
                        temp.append(wp[i])
                    }
                }
                wp = temp
            }
            //动画播放指示器
            this.animateFlag = true

            //结算血量
            if (attack_power > defence_power) {
                if (player == 1) {
                    hp1 -= damage
                } else {
                    hp2 -= damage
                }
            } else if (attack_power < defence_power) {
                if (player == 1) {
                    hp2 -= damage
                } else {
                    hp1 -= damage
                }
            }
            //更新血量
            //hp1 = max(0, hp1)
            //hp2 = max(0, hp2)
            //重置升华棋子处的魔法植物
            for (row in 0..ascend_state_copy.size) {
                for (col in 0..ascend_state_copy[0].size) {
                    if (ascend_state_copy[row][col] != 0) {
                        magic_plants_copy[row][col] = 0
                    }
                }
            }
            nc.fill(ascend_state_copy, 0)
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
        if (plant_timer > 6) {
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
    public func getGameEnded(board: Board) {
        var pieces = board[0]
        var hp1 = board[3]
        var hp2 = board[4]

        if (hp1 <= 0 && hp2 <= 0) {
            return 0
        } else if (hp1 <= 0) {
            return -1
        } else if (hp2 <= 0) {
            return 1
        }
        if (!nc.any(pieces, 0)) {
            if (hp1 > hp2) {
                return 1
            } else if (hp2 > hp1) {
                return -1
            } else {
                return 0
            }
        }
        //未结束
        return -999
    }

    /*
    计算升华状态相关数据并填充动画
     */
    public func ascend(
        pieces: Array<Array<Int64>>,
        magic_plants: Array<Array<Int64>>,
        ascend_state: Array<Array<Int64>>,
        row: Int64,
        col: Int64,
        player: Int64,
        set_ascend_value: Bool
    ) {
        var total_power = 0
        var suc_connextion = false
        let directions = [[0, 1], [1, 0], [1, 1], [1, -1]]
        //计算是否连线
        for (i in directions) {
            var dx = i[0]
            var dy = i[1]
            var connected_pos: ArrayList<Array<Int64>> = ArrayList()
            var r = 0
            var c = 0
            var power = 0

            r = row + dx
            c = col + dy
            while ((0 <= r && r < this.board_size) && (0 <= c && c < this.board_size) && pieces[r][c] == player) {
                connected_pos.append([r, c])
                r = r + dx
                c = c + dy
            }

            r = row - dx
            c = col - dy
            while ((0 <= r && r < this.board_size) && (0 <= c && c < this.board_size) && pieces[r][c] == player) {
                connected_pos.append([r, c])
                r = r - dx
                c = c - dy
            }
            power = connected_pos.size
            if (power >= 3) {
                var magic_bonus = 0
                for (pos in connected_pos) {
                    magic_bonus += magic_plants[pos[0]][pos[1]]
                    if (player == 1) {
                        wp.append([pos[0], pos[1], 1])
                    } else if (player == -1) {
                        bp.append([pos[0], pos[1], 1])
                    }
                    if (magic_plants[pos[0]][pos[1]] == 1) {
                        if (player == 1) {
                            wp.append([pos[0], pos[1], 1])
                        } else if (player == -1) {
                            bp.append([pos[0], pos[1], 1])
                        }
                    }
                }
                if (player == 1) {
                    wp.append([row, col, 1])
                    if (magic_plants[row][col] == 1) {
                        wp.append([row, col, 1])
                    }
                } else if (player == -1) {
                    bp.append([row, col, 1])
                    if (magic_plants[row][col] == 1) {
                        bp.append([row, col, 1])
                    }
                }
                suc_connextion = true
                total_power += power + magic_bonus
                for (i in connected_pos) {
                    r = i[0]
                    c = i[1]
                    if (r != row || c != col) {
                        pieces[r][c] = 0
                        if (set_ascend_value) {
                            ascend_state[r][c] = player
                        } else {
                            ascend_state[r][c] = 0
                        }
                        if (!set_ascend_value) {
                            magic_plants[r][c] = 0
                        }
                    }
                }
            }
        }

        if (suc_connextion) {
            total_power += 1 + magic_plants[row][col]
            pieces[row][col] = 0
            if (set_ascend_value) {
                ascend_state[row][col] = player
            } else {
                ascend_state[row][col] = 0
            }
            if (!set_ascend_value) {
                magic_plants[row][col] = 0
            }
        }
        sort()
        return total_power
    }

    /*
    仅计算升华状态相关数据，不操作动画
     */
    public func noani_ascend(
        pieces: Array<Array<Int64>>,
        magic_plants: Array<Array<Int64>>,
        ascend_state: Array<Array<Int64>>,
        row: Int64,
        col: Int64,
        player: Int64,
        set_ascend_value: Bool
    ) {
        var total_power = 0
        var suc_connextion = false
        let directions = [[0, 1], [1, 0], [1, 1], [1, -1]]
        //计算是否连线
        for (i in directions) {
            var dx = i[0]
            var dy = i[1]
            var connected_pos: ArrayList<Array<Int64>> = ArrayList()
            var r = 0
            var c = 0
            var power = 0

            r = row + dx
            c = col + dy
            while ((0 <= r && r < this.board_size) && (0 <= c && c < this.board_size) && pieces[r][c] == player) {
                connected_pos.append([r, c])
                r = r + dx
                c = c + dy
            }

            r = row - dx
            c = col - dy
            while ((0 <= r && r < this.board_size) && (0 <= c && c < this.board_size) && pieces[r][c] == player) {
                connected_pos.append([r, c])
                r = r - dx
                c = c - dy
            }
            power = connected_pos.size
            if (power >= 3) {
                var magic_bonus = 0
                for (pos in connected_pos) {
                    magic_bonus += magic_plants[pos[0]][pos[1]]
                }
                suc_connextion = true
                total_power += power + magic_bonus
                for (i in connected_pos) {
                    r = i[0]
                    c = i[1]
                    if (r != row || c != col) {
                        pieces[r][c] = 0
                        if (set_ascend_value) {
                            ascend_state[r][c] = player
                        } else {
                            ascend_state[r][c] = 0
                        }
                        if (!set_ascend_value) {
                            magic_plants[r][c] = 0
                        }
                    }
                }
            }
        }

        if (suc_connextion) {
            total_power += 1 + magic_plants[row][col]
            pieces[row][col] = 0
            if (set_ascend_value) {
                ascend_state[row][col] = player
            } else {
                ascend_state[row][col] = 0
            }
            if (!set_ascend_value) {
                magic_plants[row][col] = 0
            }
        }
        sort()
        return total_power
    }

    /*
    在棋盘上随机生成魔法植物
    count: 生成数量
     */
    public func spawn_magic_plants(pieces: Array<Array<Int64>>, magic_plants: Array<Array<Int64>>, count: Int64) {
        //查找可以生成魔法植物的位置
        var empty_indices: ArrayList<Array<Int64>> = ArrayList()
        for (row in 0..9) {
            for (col in 0..9) {
                if (pieces[row][col] == 0 && magic_plants[row][col] < 2) {
                    empty_indices.append([row, col])
                }
            }
        }
        //在随机位置生成魔法植物
        if (empty_indices.size >= count) {
            var selected_idx = nc.random_choice(
                empty_indices.size,
                count,
                replace: false
            )
            for (idx in selected_idx) {
                var x = empty_indices[Int64(idx)][0]
                var y = empty_indices[Int64(idx)][1]
                magic_plants[x][y] += 1
            }
        }
    }

    private func sort() {
        for (i in 0..this.wp.size) {
            for (j in 0..(this.wp.size - 1)) {
                if (wp[j][1] > wp[j + 1][1] || (wp[j][1] == wp[j][1] && wp[j][0] > wp[j + 1][0])) {
                    var temp = wp[j]
                    wp[j] = wp[j + 1]
                    wp[j + 1] = temp
                }
            }
        }

        for (i in 0..this.bp.size) {
            for (j in 0..(this.bp.size - 1)) {
                if (bp[j][1] > bp[j + 1][1] || (bp[j][1] == bp[j][1] && bp[j][0] > bp[j + 1][0])) {
                    var temp = bp[j]
                    bp[j] = bp[j + 1]
                    bp[j + 1] = temp
                }
            }
        }
    }
}

public class StupidFourAscendPlayer {
    var game: FourAscendGame
    let directions: Array<(Int64, Int64)>

    /*
    初始化
     */
    public init(game: FourAscendGame) {
        this.game = game
        this.directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
    }

    /*
    落一个子
     */
    public func play(board: Board) {
        var ascend_state = board[2]
        var valid = game.getValidMoves(board, -1)
        //获取可落子的位置的索引
        var valid_actions = ArrayList<Int64>()
        for (i in 0..valid.size) {
            if (valid[i] == 1) {
                valid_actions.append(i)
            }
        }

        if (valid_actions.size == 0) {
            return -1
        }
        var is_defense_turn = nc.any(ascend_state, 1)
        if (is_defense_turn) {
            return choose_defence_move(board, valid_actions)
        } else {
            return choose_attack_move(board, valid_actions)
        }
    }

    /*
    防御阶段的落子
     */
    public func choose_defence_move(board: Board, valid_actions: ArrayList<Int64>, player!: Int64 = -1) {
        var pieces = board[0]
        var magic_plants = board[1]
        var ascend_state = board[2]
        var opponent_player = -player
        var candidates: ArrayList<(Int64, Int64, Int64)> = ArrayList()
        //计算对方的原始攻击力
        var original_opponent_power = 0
        for (row in 0..ascend_state.size) {
            for (col in 0..ascend_state[0].size) {
                if (ascend_state[row][col] == 1) {
                    original_opponent_power += 1 + magic_plants[row][col]
                }
            }
        }

        for (action in valid_actions) {
            let row = action / this.game.board_size
            let col = action % this.game.board_size
            var test_pieces = nc.copy(pieces)
            var test_magic_plants = nc.copy(magic_plants)
            var test_ascend_state = nc.copy(ascend_state)
            var can_remove_opponent_piece = (ascend_state[row][col] == opponent_player)
            var reduced_opponent_power = original_opponent_power
            var denfence_power = 0
            var final_opponent_power = 0
            var my_damage = 0
            var opponent_damage = 0

            //检查是否可以移除对方升华状态的棋子
            if (can_remove_opponent_piece) {
                test_ascend_state[row][col] = 0
                reduced_opponent_power = nc.sum(test_ascend_state)
                for (row in 0..test_ascend_state.size) {
                    for (col in 0..test_ascend_state[0].size) {
                        if (test_ascend_state[row][col] == 1) {
                            reduced_opponent_power += 1
                        }
                    }
                }
            }

            test_pieces[row][col] = player
            denfence_power = game.noani_ascend(
                test_pieces,
                test_magic_plants,
                test_ascend_state,
                row,
                col,
                player,
                false
            )
            final_opponent_power = reduced_opponent_power
            var damage = abs(final_opponent_power - denfence_power)
            if (final_opponent_power > denfence_power) {
                my_damage = damage
                opponent_damage = 0
            } else if (final_opponent_power < denfence_power) {
                my_damage = 0
                opponent_damage = damage
            } else {
                my_damage = 0
                opponent_damage = 0
            }

            candidates.append((action, my_damage, opponent_damage))
        }

        //无法落子
        if (candidates.size == 0) {
            return valid_actions[0]
        }
        //选择对自己伤害最小的位置
        var min_my_damage = candidates[0][1]
        for (i in candidates) {
            if (i[1] < min_my_damage) {
                min_my_damage = i[1]
            }
        }
        //在对自己伤害最小的位置中，选择对对手伤害最大的位置
        var best_candidates: ArrayList<(Int64, Int64, Int64)> = ArrayList()
        for (i in candidates) {
            if (i[1] == min_my_damage) {
                best_candidates.append(i)
            }
        }
        var max_opponent_damage = best_candidates[0][2]
        for (i in best_candidates) {
            if (i[2] > max_opponent_damage) {
                max_opponent_damage = i[2]
            }
        }
        var best_action = best_candidates[0][0]
        for (i in best_candidates) {
            if (i[2] == max_opponent_damage) {
                best_action = i[0]
            }
        }

        return best_action
    }

    /*
    攻击阶段：优先阻止对方高伤害位置，但检查自身安全；否则延长自己连线
     */
    public func choose_attack_move(board: Board, valid_actions: ArrayList<Int64>) {
        var pieces = board[0]
        var magic_plants = board[1]

        //阻止对方攻击力高的位置
        var max_damage = 0
        var best_action = -1

        for (action in valid_actions) {
            var damage = calculate_potential_damage(board, action, 1)
            if (damage > max_damage) {
                max_damage = damage
                best_action = action
            }
        }
        if (best_action != -1 && max_damage > 0) {
            if (is_safe_to_attack(board, best_action)) {
                return best_action
            }
        }

        //尝试连成3子
        var three_move = find_three_connection_move(pieces, magic_plants, -1, valid_actions)
        if (three_move != -1) {
            return three_move
        }

        //尝试连成4子
        var win_move = find_winning_move(pieces, magic_plants, -1, valid_actions)
        if (win_move != -1) {
            return win_move
        }

        //尝试寻找一般情况下的最佳位置
        return choose_best_position(pieces, magic_plants, -1, valid_actions)
    }

    /*
    寻找能连成4子的位置
     */
    public func find_winning_move(pieces: Array<Array<Int64>>, magic_plants: Array<Array<Int64>>, player: Int64,
        valid_actions: ArrayList<Int64>) {
        var best_action = -1

        for (action in valid_actions) {
            let row = action / this.game.board_size
            let col = action % this.game.board_size
            if (can_form_four(pieces, row, col, player)) {
                best_action = action
            }
        }

        return best_action
    }

    /*
    寻找能连成3子的位置
     */
    public func find_three_connection_move(pieces: Array<Array<Int64>>, magic_plants: Array<Array<Int64>>,
        player: Int64, valid_actions: ArrayList<Int64>) {
        var best_action = -1
        var best_power = 0

        for (action in valid_actions) {
            let row = action / this.game.board_size
            let col = action % this.game.board_size
            var test_pieces = nc.copy(pieces)
            var test_magic_plants = nc.copy(magic_plants)
            var test_ascend_state = nc.zeros(pieces.size, pieces[0].size)

            test_pieces[row][col] = player
            var power = game.noani_ascend(
                test_pieces,
                test_magic_plants,
                test_ascend_state,
                row,
                col,
                player,
                true
            )
            if (power != 0 && power > best_power) {
                best_power = power
                best_action = action
            }
        }

        return best_action
    }

    /*
    检查在指定位置下棋是否能连成4子
     */
    public func can_form_four(pieces: Array<Array<Int64>>, row: Int64, col: Int64, player: Int64) {
        var test_pieces = nc.copy(pieces)

        test_pieces[row][col] = player
        for (pos in this.directions) {
            let dx = pos[0]
            let dy = pos[1]
            var count = 1

            var r = row + dx
            var c = col + dy
            while ((0 <= r && r < this.game.board_size) && (0 <= c && c < this.game.board_size) && test_pieces[r][c] ==
                    player) {
                count += 1
                r = r + dx
                c = c + dy
            }

            r = row - dx
            c = col - dy
            while ((0 <= r && r < this.game.board_size) && (0 <= c && c < this.game.board_size) && test_pieces[r][c] ==
                    player) {
                count += 1
                r = r - dx
                c = c - dy
            }

            if (count >= 4) {
                return true
            }
        }

        return false
    }

    /*
    选择最佳位置
     */
    public func choose_best_position(pieces: Array<Array<Int64>>, magic_plants: Array<Array<Int64>>, player: Int64,
        valid_actions: ArrayList<Int64>) {
        var best_action = -1
        var best_score = 0

        for (action in valid_actions) {
            let row = action / this.game.board_size
            let col = action % this.game.board_size
            var score = evaluate_position(pieces, magic_plants, row, col, player)

            if (score > best_score) {
                best_score = score
                best_action = action
            }
        }

        return best_action
    }

    /*
    评估位置价值（启发式评估）
     */
    public func evaluate_position(pieces: Array<Array<Int64>>, magic_plants: Array<Array<Int64>>, row: Int64,
        col: Int64, player: Int64) {
        var score = 0
        var center = this.game.board_size / 2
        var distance_to_center = 0

        score += magic_plants[row][col] * 2
        distance_to_center = abs(row - center) + abs(col - center)
        score += max(0, center - distance_to_center)
        for (i in this.directions) {
            let dx = i[0]
            let dy = i[1]

            var line_score = evaluate_line(pieces, row, col, dx, dy, player)
            score += line_score
        }

        return score
    }

    /*
    评估某个方向的连接潜力
     */
    public func evaluate_line(pieces: Array<Array<Int64>>, row: Int64, col: Int64, dx: Int64, dy: Int64, player: Int64) {
        var score = 0
        var my_pieces = 0
        var empty_spaces = 0
        var opponent_pieces = 0

        for (d in [1, -1]) {
            var r = row + d * dx
            var c = col + d * dy

            for (i in 0..3) {
                if ((0 <= r && r < this.game.board_size) && (0 <= c && c < this.game.board_size)) {
                    if (pieces[r][c] == player) {
                        my_pieces += 1
                    } else if (pieces[r][c] == 0) {
                        empty_spaces += 0
                    } else {
                        opponent_pieces += 1
                        break
                    }
                    r = r + d * dx
                    c = c + d * dy
                } else {
                    break
                }
            }
        }

        if (opponent_pieces == 0) {
            if (my_pieces >= 2) {
                score += 10 * my_pieces
            } else if (my_pieces == 1) {
                score += 3
            }
            score += empty_spaces
        }

        return score
    }

    /*
    计算对方下子后的潜在攻击威力
     */
    public func calculate_potential_damage(board: Board, action: Int64, opponent_player: Int64) {
        let pieces = board[0]
        let magic_plants = board[1]
        let ascend_state = board[2]
        var pieces_copy = nc.copy(pieces)
        var magic_plants_copy = nc.copy(magic_plants)
        var ascend_state_copy = nc.copy(ascend_state)

        let row = action / this.game.board_size
        let col = action % this.game.board_size
        pieces_copy[row][col] = opponent_player

        var attack_power = game.noani_ascend(
            pieces_copy,
            magic_plants_copy,
            ascend_state_copy,
            row,
            col,
            opponent_player,
            true
        )
        return attack_power
    }

    //检查下子后是否会导致自己受到伤害
    public func is_safe_to_attack(board: Board, action: Int64) {
        let pieces = board[0]
        let magic_plants = board[1]
        let ascend_state = board[2]
        var hp1 = board[3]
        var hp2 = board[4]
        var plant_timer = board[5]

        let row = action / this.game.board_size
        let col = action % this.game.board_size
        var pieces_copy = nc.copy(pieces)
        var magic_plants_copy = nc.copy(magic_plants)
        var ascend_state_copy = nc.copy(ascend_state)

        pieces_copy[row][col] = -1
        var attack_power = game.noani_ascend(
            pieces_copy,
            magic_plants_copy,
            ascend_state_copy,
            row,
            col,
            -1,
            true
        )
        //不会对对手造成伤害
        if (attack_power == 0) {
            return true
        }
        //对对手有伤害，模拟对手防御
        var opponent_ai = StupidFourAscendPlayer(this.game)
        var valid = game.getValidMoves((pieces_copy, magic_plants_copy, ascend_state_copy, hp1, hp2, plant_timer), 1)
        var valid_actions = ArrayList<Int64>()
        for (i in 0..valid.size) {
            if (valid[i] == 1) {
                valid_actions.append(i)
            }
        }
        if (valid_actions.size == 0) {
            return true
        }
        var denfence_action = opponent_ai.choose_defence_move(
            (pieces_copy, magic_plants_copy, ascend_state_copy, hp1, hp2, plant_timer), valid_actions, player: 1)

        //模拟对手下子
        var d_row = denfence_action / this.game.board_size
        var d_col = denfence_action % this.game.board_size
        var pieces_copy2 = nc.copy(pieces)
        var magic_plants_copy2 = nc.copy(magic_plants)
        var ascend_state_copy2 = nc.copy(ascend_state)

        pieces_copy2[d_row][d_col] = 1
        var denfence_power = game.noani_ascend(
            pieces_copy2,
            magic_plants_copy2,
            ascend_state_copy2,
            d_row,
            d_col,
            1,
            false
        )
        //计算是否受伤
        if (attack_power > denfence_power) {
            return false
        } else {
            return true
        }
    }
}
