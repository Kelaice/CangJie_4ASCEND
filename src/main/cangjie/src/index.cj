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
    @State
    var Welopa :Float64 = 1.0
    var timer: ?Timer = None
    var WelFlag: Bool = true

    protected override func onPageShow() {
        // 创建定时器，每秒钟触发一次游戏更新
        if(step == 0)
        {
            this.timer = Timer.repeat(Duration.Zero, Duration.second / 10,
                {
                    =>
                        if(WelFlag)
                        {
                        this.Welopa -= 0.05
                    }
                    else{
                        this.Welopa += 0.05
                    }

                    if(this.Welopa < 0.5)
                    {
                        this.WelFlag = false
                    }
                    else if (this.Welopa > 1.0)
                    {
                        this.WelFlag = true
                    }
                }
                , style: CatchupStyle.Skip)
        }
        if(step != 0){
            this.timer?.cancel() // 取消定时器，避免资源浪费
        }
    }

    protected override func onPageHide(): Unit {
        this.timer?.cancel() // 取消定时器，避免资源浪费
    }


    func build()  {
        Column {
            //背景图片
            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            if(step == 0) {//标题界面
                WelcomePageFont(Welopa :this.Welopa,step :this.step)
            }
            else if(step == 1)
            {
                MenuPage(step :this.step)
            }
            else if(step == 2) {//游戏界面
                testboard(data :this.data, game :game, game_state :this.game_state, player :this.player, step :this.step)
                playerstate(game_state :this.game_state)
            }
            else if(step == 3) {//结束界面
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