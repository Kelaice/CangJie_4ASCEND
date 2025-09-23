package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.*
import cj_res_entry.*
import ohos.hilog.Hilog
import ohos_app_cangjie_entry.game_body.*
import std.sync.*
import ohos.font.*
import std.time.*
import ohos.router.*

//所需的类型定义
type ObservedMatrix = ObservedArray<Int64>
type OpacityMatrix = ObservedArray<Float64>
type Board = (Array<Array<Int64>>,
                Array<Array<Int64>>,
                Array<Array<Int64>>,
                Int64,
                Int64,
                Int64)

//游戏初始化
var game :FourAscendGame = FourAscendGame(9, 6, 6)
var ai :StupidFourAscendPlayer = StupidFourAscendPlayer(game)

@Entry
@Component
class EntryView {
    @State//data:棋盘数据
    var data :ObservedMatrix = ObservedArray<Int64>(Array<Int64>(81,{_=>0}))

    @State//opacityArray:棋子透明度
    var opacityArray :OpacityMatrix = ObservedArray<Float64>(Array<Float64>(81,{_=>0.8}))

    @State//game_state:游戏状态
    var game_state :Board = game.getInitBoard()
    @State//player:当前玩家，1为1号，-1为2号
    var player :Int64 = 1
    @State//step:游戏显示状态指示器
    var step :Int64 = 0

    @State
    var WelFontOpacity :Float64 = 0.8
    @State
    var WelOpacity :Float64 = 1.0


    protected override func aboutToAppear() {
        Font.registerFont(
            familyName: @r(app.string.ProggyTinySZ),
            familySrc: @rawfile("ProggyTinySZ.ttf")
        )
    }

    func build()  {
        Column {
            //背景图片
            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            if(step == 0) {
                //标题界面
                WelcomePage(
                    step :this.step,
                    WelFontOpacity :this.WelFontOpacity,
                    WelOpacity :this.WelOpacity)
            }
            else if(step == 1)
            {
               MenuPage(step :this.step)
            }
            else if(step == 2) {//PVP游戏界面
                chessGrid()

                testboard(
                    data :this.data,
                    game :game,
                    game_state :this.game_state,
                    player :this.player,
                    step :this.step,
                    opacityArray :this.opacityArray,
                    mode :1,
                    AI :ai
                    )

                playerstate(game_state :this.game_state)
            }
            else if(step == 3) {//PVE游戏界面
                chessGrid()

                testboard(
                    data :this.data,
                    game :game,
                    game_state :this.game_state,
                    player :this.player,
                    step :this.step,
                    mode :2,
                    AI :ai,
                    opacityArray :this.opacityArray)

                playerstate(game_state :this.game_state)
            }
            else if(step == 4) {//结束界面
                GameEndPage(game :game, step :this.step)
            }
            else if(step == 5) {//教学界面

            }

        }
        .width(100.percent)
        .height(100.percent)
    }
}