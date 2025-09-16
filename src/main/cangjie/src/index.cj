package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import cj_res_entry.*
import ohos.hilog.Hilog
import ohos_app_cangjie_entry.game_body.*

//所需的类型定义
type ObservedMatrix = ObservedArray<Int64>
type Board = (Array<Array<Int64>>,
                Array<Array<Int64>>,
                Array<Array<Int64>>,
                Int64,
                Int64,
                Int64)

//游戏类型初始化
var game :FourAscendGame = FourAscendGame(9, 6, 6)

@Entry
@Component
class EntryView {
    @State//data:棋盘数据
    var data :ObservedMatrix = ObservedArray<Int64>(Array<Int64>(81,{_=>0}))
    @State//game_state:游戏状态
    var game_state :Board = game.getInitBoard()
    @State//player:当前玩家，1为1号，-1为2号
    var player :Int64 = 1
    @State//step:游戏显示状态指示器
    var step :Int64 = 0

    func build()  {
        Column {
            //背景图片
            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            if(step == 0) {//标题界面
                Image(@r(app.media.titleBackground))
                .height(400)
                .width(860)
                .position(x: 0, y: 0)
                .onClick({evt => step=1 })
            }
            else if(step == 1) {//游戏界面
                testboard(data :this.data, game :game, game_state :this.game_state, player :this.player, step :this.step)
                playerstate(game_state :this.game_state)
            }
            else if(step == 2) {//结束界面
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