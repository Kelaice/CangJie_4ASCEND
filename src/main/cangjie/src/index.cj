package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import cj_res_entry.*
import ohos_app_cangjie_entry.game_body.*
import ohos.hilog.Hilog

type ObservedMatrix = ObservedArray<Int64>
type Board = (Array<Array<Int64>>,
                Array<Array<Int64>>,
                Array<Array<Int64>>,
                Int64,
                Int64,
                Int64)

var game :FourAscendGame = FourAscendGame(9, 6, 6)

@Entry
@Component
class EntryView {
    @State
    var data :ObservedMatrix = ObservedArray<Int64>(Array<Int64>(81,{_=>0}))
    @State
    var game_state :Board = game.getInitBoard()
    @State
    var player :Int64 = 1
    @State
    var step :Int64 = 0

    func build()  {
        Column {

            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            if(step == 0) {
                Image(@r(app.media.titleBackground))
                .height(400)
                .width(860)
                .position(x: 0, y: 0)
                .onClick({evt => step=1 })
            }
            else if(step == 1) {
                testboard(data :this.data, game :game, game_state :this.game_state, player :this.player, step :this.step)
                playerstate(game_state :this.game_state)
            }
            else if(step == 2) {
                Image(@r(app.media.Game_End_Image))
                .height(400)
                .width(860)
                .position(x: 0, y: 0)

                Text("Game Over!")
                .position(x: 350, y: 200)
                .fontSize(50)
            }

        }
        .width(100.percent)
        .height(100.percent)
    }
}

@Component
public class testboard {
    @Link var data :ObservedMatrix
    @Link var game :FourAscendGame
    @Link var game_state :Board
    @Link var player :Int64
    @Link var step :Int64

    func OtoA() {
        var res = Array<Int64>(81, {_=>0})
        for(i in 0..81) {
            res[i] = this.data[i]
        }
        return res
    }

    func AtoO(array :Array<Int64>) {
        for(i in 0..81) {
            this.data[i] = array[i]
        }
    }

    func build() {
        Stack {
            Grid {
                ForEach(data, itemGeneratorFunc :{entity :Int64, index :Int64 =>
                            GridItem {
                                Image(@r(app.media.chessGridItem))
                                .onClick(
                                    {evt =>
                                            if(data[index] == 0) {
                                                data[index] = player
                                                var pieces1 = nc.fold(OtoA(), 9, 9)
                                                var new_game_state :Board= game.getNextState(
                                                                    (pieces1,
                                                                    this.game_state[1],
                                                                    this.game_state[2],
                                                                    this.game_state[3],
                                                                    this.game_state[4],
                                                                    this.game_state[5]
                                                                    ),
                                                                    player, index
                                                                                            )
                                                var pieces2 = nc.flatten(new_game_state[0], 81)
                                                AtoO(pieces2)

                                                if(game.getGameEnded(new_game_state) == -999) {
                                                    player = -player
                                                    this.game_state = new_game_state
                                                }
                                                else {
                                                    this.step = 2
                                                }


                                             }
                                    }
                                )

                                if(data[index]==1) {
                                    Image(@r(app.media.white_Chess))
                                    .alt(@r(app.media.chessGridItem))
                                    .height(30)
                                    .width(30)
                                }
                                else if(data[index] == -1) {
                                    Image(@r(app.media.black_Chess))
                                    .alt(@r(app.media.chessGridItem))
                                    .height(30)
                                    .width(30)
                                }
                            }
                            .height(40)
                            .width(40)
                    }
                )
            }
            .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
            .height(360)
            .width(360)
            .position(x: 0, y: 10)
        }
    }
}

@Component
public class playerstate {
    @Prop var game_state :Board

    var y_pos = 200
    var x_pos = 100

    func build() {
        Column {
            Image(@r(app.media.HP_Image))
            .position(x: x_pos, y: y_pos)
            .height(37)
            .width(40)
            Text("${game_state[3]}")
            .textAlign(TextAlign.Center)
            .fontSize(30)
            .fontColor(0xfc037f)
            .position(x: x_pos +10, y: y_pos +50)
            .height(50)
            .height(50)

            Image(@r(app.media.HP_Image))
            .position(x:x_pos +600, y: y_pos)
            .height(37)
            .width(40)
            Text("${game_state[4]}")
            .textAlign(TextAlign.Center)
            .fontSize(30)
            .fontColor(0xfc037f)
            .position(x: x_pos +600 +10, y: y_pos +50)
            .height(50)
            .height(50)
        }
    }
}