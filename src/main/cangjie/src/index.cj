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
    @State//pre_step:动画状态显示器
    var pre_step = -1
    //计时器
    var timer: ?Timer = None
    //欢迎界面动画参量
    @State
    var Welopa :Float64 = 1.0
    @State
    var WelAniOpa :Float64 = 1.0
    var WelFlag: Bool = true
    //菜单界面动画参量
    @State
    var MenuAniOpa :Float64 = 0.0
    @State var PVP_Button_x :Int64 = 325
    @State var PVP_Button_y :Int64 = 150
    @State var Learn_Button_x :Int64 = 325
    @State var Learn_Button_y :Int64 = 150

    protected override func onPageShow() {
        // 创建定时器，每秒钟触发一次游戏更新
        if(step == 0)
        {
            this.timer = Timer.repeat(Duration.Zero, Duration.second / 50,
                {=>
//---------------------------------以下是欢迎页面的动画处理--------------------------------------------------
                        if(WelFlag){
                        this.Welopa -= 0.01
                    }
                    else
                    {
                        this.Welopa += 0.01
                    }

                    if(this.Welopa < 0.5)
                    {
                        this.WelFlag = false
                    }
                    else if (this.Welopa > 1.0)
                    {
                        this.WelFlag = true
                    }
                    //欢迎页面切换至菜单页面动画
                    if (this.pre_step == 0 && this.step == 1)
                    {
                        this.WelAniOpa -= 0.04
                        if(WelAniOpa <= 0.0)
                        {
                            this.pre_step = -1
                        }
                    }
//------------------------------------以下是菜单页面的动画处理-----------------------------------------------
                    if (this.step == 1 && this.pre_step == -1)
                    {
                        if(MenuAniOpa < 1.0)
                        {
                            MenuAniOpa += 0.04
                        }
                        if (MenuAniOpa >= 1.0)
                        {
                            if (PVP_Button_x > 200)
                            {
                                PVP_Button_x -= 5
                                PVP_Button_y -= 4
                            }
                            if (Learn_Button_x < 450)
                            {
                                Learn_Button_x += 5
                                Learn_Button_y += 4
                            }
                        }
                    }
                }
                , style: CatchupStyle.Skip)
        }
        if(step != 0){
            this.timer?.cancel() // 取消定时器，避免资源浪费
        }
    }

    protected override func onPageHide(): Unit {
    }

    func build()  {
        Column {
            //背景图片
            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            if(step == 0 || pre_step == 0) {
                //标题界面
                WelcomePageFont(Welopa :this.Welopa,step :this.step,pre_step :this.pre_step,WelAniOpa :this.WelAniOpa)
            }
            else if(step == 1)
            {
               MenuPage(step :this.step
                    ,MenuAniOpa :this.MenuAniOpa
                    ,PVP_Button_x :this.PVP_Button_x
                    ,PVP_Button_y :this.PVP_Button_y
                    ,Learn_Button_x :this.Learn_Button_x
                    ,Learn_Button_y :this.Learn_Button_y)
            }
            else if(step == 2) {//游戏界面
                testboard(data :this.data, game :game, game_state :this.game_state, player :this.player, step :this.step)
                playerstate(game_state :this.game_state)
            }
            else if(step == 3) {//结束界面
                GameEndPage(hp1 :this.game_state[3],hp2 :this.game_state[4],step :this.step)
            }

        }
        .width(100.percent)
        .height(100.percent)
    }
}