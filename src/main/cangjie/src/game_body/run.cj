package ohos_app_cangjie_entry.game_body

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*


//一次落子之后的数据运算，并返回新的状态
public func run(data :ObservedMatrix, game :FourAscendGame, game_state :Board, index :Int64, player :Int64, step :Int64)
:(Int64, Int64, Board){
    var new_step = step
    var next_player = player

    if(data[index] == 0) {
        data[index] = player
        var pieces1 = nc.fold(OtoA(data), 9, 9)
        var new_game_state :Board= game.getNextState(
                            (pieces1,
                            game_state[1],
                            game_state[2],
                            game_state[3],
                            game_state[4],
                            game_state[5]
                            ),
                            player, index
                                                    )
        var pieces2 = nc.flatten(new_game_state[0], 81)
        AtoO(data,pieces2)

        if(game.getGameEnded(new_game_state) == -999) {
            next_player = -player
        }
        else {
            new_step = 3
        }

        return (new_step, next_player, new_game_state)
     }
    return (step, player, game_state)
}

private func OtoA(data :ObservedMatrix) {
        var res = Array<Int64>(81, {_=>0})
        for(i in 0..81) {
            res[i] = data[i]
        }
        return res
    }

private func AtoO(data :ObservedMatrix, array :Array<Int64>) {
    for(i in 0..81) {
        data[i] = array[i]
    }
}