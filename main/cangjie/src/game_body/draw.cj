package ohos_app_cangjie_entry.game_body

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.sync.*
import ohos.font.*
import std.time.*

type ObservedMatrix = ObservedArray<Int64>

//棋盘绘制组件
@Component
public class testboard {
    @Link var data :ObservedMatrix
    @Link var game :FourAscendGame
    @Link var game_state :Board
    @Link var player :Int64
    @Link var step :Int64
    @Link var ascendOpa :Float64

    protected func CheckAscendState(index :Int64)
    {
        if (game_state[2][index / 9][index % 9] != 0)
        {
            return ascendOpa
        }
        else{
            return 1.0
        }
    }

    func build() {
        Stack {
            Grid {
                ForEach(data, itemGeneratorFunc :{entity :Int64, index :Int64 =>
                            GridItem {
                            Stack{
                                Image(@r(app.media.chessGridItem))

                                //显示白子
                                if(data[index] == 1 || game_state[2][index / 9][index % 9] == 1) {
                                    Image(@r(app.media.white_Chess))
                                    .height(30)
                                    .width(30)
                                    .opacity(CheckAscendState(index))
                                }
                                //显示黑子
                                else if(data[index] == -1 || game_state[2][index / 9][index % 9] == -1) {
                                    Image(@r(app.media.black_Chess))
                                    .height(30)
                                    .width(30)
                                    .opacity(CheckAscendState(index))
                                }
                            }.onClick(
                                    {evt =>
                                        var back :(Int64,Int64,Board)= run(this.data, this.game, this.game_state, index, this.player, this.step)
                                        this.step = back[0]
                                        this.player = back[1]
                                        this.game_state = back[2]
                                    }
                                )
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

//玩家状态绘制组件
@Component
public class playerstate {
    @Prop var game_state :Board

    var y_pos = 200
    var x_pos = 100

    func build() {
        Column {
            Image(@r(app.media.player))
            .position(x: 90, y: 310)
            .height(62)
            .width(63)
            Image(@r(app.media.HP_Image))
            .position(x: x_pos, y: y_pos+50)
            .height(40)
            .width(40)
            Text("${game_state[3]}")
            .textAlign(TextAlign.Center)
            .fontSize(30)
            .fontColor(0xfc037f)
            .position(x: x_pos +55, y: y_pos +45)
            .height(50)
            .height(50)
            .rotate(-90)

            Image(@r(app.media.enemy))
            .position(x: 690, y: 15)
            .height(57)
            .width(58)
            Image(@r(app.media.HP_Image))
            .position(x:x_pos +600, y: y_pos-120+5)
            .height(40)
            .width(40)
            Text("${game_state[4]}")
            .textAlign(TextAlign.Center)
            .fontSize(30)
            .fontColor(0xfc037f)
            .position(x: x_pos +600 +55, y: y_pos -120)
            .height(50)
            .height(50)
            .rotate(-90)
        }
    }

}