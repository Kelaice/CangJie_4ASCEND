package ohos_app_cangjie_entry.game_body

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.sync.*
import ohos.font.*
import std.time.*
import ohos.crypto.Random

type ObservedMatrix = ObservedArray<Int64>
type OpacityMatrix = ObservedArray<Float64>

//棋盘绘制组件
@Component
public class chessGrid {
    func build() {
        Grid {
                ForEach(Array<Int64>(81,{_=>0}), itemGeneratorFunc :{entity :Int64, index :Int64 =>
                        GridItem {
                            Image(@r(app.media.chessGridItem))
                        }
                    }
                )
        }
        .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
        .height(360)
        .width(360)
        .position(x: 249, y: 10)
    }
}

@Component
public class testboard {
    @Link var data :ObservedMatrix
    @Link var game :FourAscendGame
    @Link var game_state :Board
    @Link var player :Int64
    @Link var step :Int64
    @Link var AI :StupidFourAscendPlayer
    @Link var opacityArray :OpacityMatrix
    @Prop var mode :Int64

    let animateOpt = AnimateParam(
        duration: 600,
        curve: Curve.Smooth,
        delay: 0,
        iterations: -1, // 设置-1表示动画无限循环
        playMode: PlayMode.Alternate,
        onFinish: {
            => AppLog.info("onfinish")
                },
        expectedFrameRateRange: ExpectedFrameRateRange(
            min: 20,
            max: 120,
            expected: 90
            )
        )

    func changeOpacity(ascend_state:Array<Array<Int64>>)
    {
        for (i in 0..9)
        {
            for(j in 0..9)
            {
                if(ascend_state[i][j] == 1)
                {
                    this.opacityArray[i * 9 + j] = 0.8 - 0.5 * Float64(ascend_state[i][j])
                }
                else {
                    this.opacityArray[i * 9 + j] = 0.8 + 0.5 * Float64(ascend_state[i][j])
                }
            }
        }
    }

    func build() {
        Stack {
            Grid {
                ForEach(data, itemGeneratorFunc :{entity :Int64, index :Int64 =>
                            GridItem {

                                //显示魔法白子
                                if(data[index] == 1 && this.game_state[1][index/9][index%9] == 1) {
                                    Image(@r(app.media.White_Chess_Plant))
                                    .height(30.0)
                                    .width(30.0)
                                }
                                else if(data[index] == 0 && this.game_state[1][index/9][index%9] == 1 && this.game_state[2][index/9][index%9] == 1) {
                                    Image(@r(app.media.White_Chess_Plant))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        =>
                                        changeOpacity(this.game_state[2])})
                                    .animationEnd()
                                }//显示魔法黑子
                                else if(data[index] == -1 && this.game_state[1][index/9][index%9] == 1) {
                                    Image(@r(app.media.Black_Chess_Plant))
                                    .height(30.0)
                                    .width(30.0)
                                }
                                else if(data[index] == 0 && this.game_state[1][index/9][index%9] == 1 && this.game_state[2][index/9][index%9] == -1) {
                                    Image(@r(app.media.Black_Chess_Plant))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        =>
                                        changeOpacity(this.game_state[2])})
                                    .animationEnd()
                                }
                                //显示白子
                                else if(data[index] == 1) {
                                    Image(@r(app.media.white_Chess))
                                    .height(30.0)
                                    .width(30.0)
                                }
                                else if(data[index] == 0 && this.game_state[2][index/9][index%9] == 1) {
                                    Image(@r(app.media.white_Chess))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        =>
                                        changeOpacity(this.game_state[2])})
                                    .animationEnd()
                                }
                                //显示黑子
                                else if(data[index] == -1) {
                                    Image(@r(app.media.black_Chess))
                                    .height(30.0)
                                    .width(30.0)
                                }
                                else if(data[index] == 0 && this.game_state[2][index/9][index%9] == -1) {
                                    Image(@r(app.media.black_Chess))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        =>
                                        changeOpacity(this.game_state[2])})
                                    .animationEnd()
                                }

                                //显示魔法植物
                                if(game_state[1][index/9][index%9] == 1 && data[index] == 0 && game_state[2][index/9][index%9] == 0) {
                                    Rect(width: 10, height: 10)
                                    .foregroundColor(0xf7e200)
                                }

                            }
                            .height(40)
                            .width(40)
                            .onClick(
                                {evt =>
                                    if(data[index] == 0) {
                                        var back :(Int64,Int64,Board)= run(this.data, this.game, this.game_state, index, this.player, this.step)
                                        this.step = back[0]
                                        this.player = back[1]
                                        this.game_state = back[2]

                                    }
                                    if(mode == 2 && this.player == -1) {
                                        var ai_move = ai_move(this.AI, this.game_state)
                                        var back :(Int64,Int64,Board)= run(this.data, this.game, this.game_state, ai_move, this.player, this.step)
                                        this.step = back[0]
                                        this.player = back[1]
                                        this.game_state = back[2]
                                    }
                                }
                            )

                    }
                )
            }
            .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ')
            .height(360)
            .width(360)
            .position(x: 10, y: 10)
        }
    }
}

//玩家状态绘制组件
@Component
public class playerstate {
    @Prop var game_state :Board

    var y_pos = 180
    var x_pos = 100

    func build() {
        Column {
            Image(@r(app.media.player))
            .position(x: x_pos -10, y: y_pos -80)
            .height(62)
            .width(63)
            .objectFit(ImageFit.Contain)
            Image(@r(app.media.HP_Image))
            .position(x: x_pos, y: y_pos)
            .height(37)
            .width(40)
            Text("${game_state[3]}")
            .textAlign(TextAlign.Center)
            .fontSize(60)
            .fontColor(0xfc037f)
            .position(x: x_pos +10, y: y_pos +50)
            .height(50)
            .fontFamily(@r(app.string.ProggyTinySZ))

            Image(@r(app.media.enemy))
            .position(x: x_pos +600-10, y: y_pos - 78)
            .height(62)
            .width(63)
            .objectFit(ImageFit.Contain)
            Image(@r(app.media.HP_Image))
            .position(x:x_pos +600, y: y_pos)
            .height(37)
            .width(40)
            Text("${game_state[4]}")
            .textAlign(TextAlign.Center)
            .fontSize(60)
            .fontColor(0xfc037f)
            .position(x: x_pos +600 +10, y: y_pos +50)
            .height(50)
            .fontFamily(@r(app.string.ProggyTinySZ))
        }
    }
}

//标题页绘制组件
@Component
public class WelcomePage{
    @Link var step :Int64
    @Link var WelFontOpacity :Float64
    @Link var WelOpacity :Float64

    let animateOpt = AnimateParam(
        duration: 600,
        curve: Curve.Linear,
        delay: 0,
        iterations: -1, // 设置-1表示动画无限循环
        playMode: PlayMode.Alternate,
        onFinish: {
            => AppLog.info("onfinish")
        },
        expectedFrameRateRange: ExpectedFrameRateRange(
            min: 20,
            max: 120,
            expected: 90
        )
    )
    let animateOpt1 = AnimateParam(
        duration: 600,
        curve: Curve.Linear,
        delay: 0,
        iterations: 1, // 设置-1表示动画无限循环
        playMode: PlayMode.Alternate,
        onFinish: {
            => AppLog.info("onfinish")
        },
        expectedFrameRateRange: ExpectedFrameRateRange(
            min: 20,
            max: 120,
            expected: 90
        )
    )

    func build()
    {
        Stack{
            Image(@r(app.media.titleBackground))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            Text("Touch Screen To Start.")
            .animationStart(animateOpt)
            .fontSize(50)
            .position(x: 200, y: 300)
            .height(35)
            .width(450)
            .opacity(this.WelFontOpacity)
            .fontFamily(@r(app.string.ProggyTinySZ))
            .onAppear({
                =>
                if (this.step == 0)
                    {
                        this.WelFontOpacity = 0.3
                    }
                    else {
                        this.WelFontOpacity = 0.8
                    }

            })
            .animationEnd()
        }.animationStart(animateOpt1)
        .onClick({
            evt=>
            step = 1
            this.WelOpacity = 0.0
        })
        .opacity(WelOpacity)
        .animationEnd()
    }
}

//菜单页绘制组件
@Component
public class MenuPage{

    var MenuFlag :Bool = true
    @Link var step :Int64

    public func build()
    {
        Stack{
            Image(@r(app.media.background4))
            .height(400)
            .width(860)
            .position(x: 0, y: -5)

            Image(@r(app.media.Menu_border))
            .height(400)
            .width(860)
            .position(x: 0, y: -5)

            Image(@r(app.media.Menu_Button_PVP))
            .height(86)
            .width(203)
            .position(x: 150, y: 50)
            .objectFit(ImageFit.Contain)
            .onClick({
                evt=>
                this.step = 2
            })


            Image(@r(app.media.Menu_Button_Learn))
            .height(86)
            .width(203)
            .position(x: 500, y: 250)
            .objectFit(ImageFit.Contain)
            .onClick({
                evt=>
                this.step = 2
            })

            Image(@r(app.media.Menu_Button_PVE))
            .height(86)
            .width(203)
            .position(x: 325, y: 150)
            .objectFit(ImageFit.Contain)
            .onClick({
                evt=>
                this.step = 3
            })
        }
    }
}

//结束页绘制组件
@Component
public class GameEndPage
{
    @Link var game :FourAscendGame
    @Link var step :Int64

    var P1_PosX: Int64 = 230
    var P1_PosY: Int64 = 150

    var P2_PosX: Int64 = 580
    var P2_PosY: Int64 = 150

    @Link var P1_angle:Float32
    @Link var P1_height: Int64
    @Link var P1_width: Int64


    @Link var P2_angle:Float32
    @Link var P2_height: Int64
    @Link var P2_width: Int64


    let animateOpt = AnimateParam(
        duration: 800,
        curve: Curve.Smooth,
        delay: 0,
        iterations: -1, // 设置-1表示动画无限循环
        playMode: PlayMode.Alternate,
        onFinish: {
            => AppLog.info("onfinish")
                },
        expectedFrameRateRange: ExpectedFrameRateRange(
            min: 20,
            max: 120,
            expected: 90
            )
        )

    func build()
    {
        Stack{
            if(step == 4)
            {
                Image(@r(app.media.Game_End_Image))
                .height(400)
                .width(860)
                .position(x: 0, y: 0)
                if(game.hp1 > 0)
                {
                     Text("P1 Wins !")
                    .position(x: 300, y: 50)
                    .fontSize(80)
                    .fontFamily(@r(app.string.ProggyTinySZ))
                }
                else
                {
                    Text("P2 Wins !")
                    .position(x: 300, y: 50)
                    .fontSize(80)
                    .fontFamily(@r(app.string.ProggyTinySZ))
                }

                Image(@r(app.media.player))
                .animationStart(animateOpt)
                .position(x: P1_PosX, y: P1_PosY)
                .height(P1_height)
                .width(P1_width)
                .objectFit(ImageFit.Fill)
                .rotate(P1_angle)
                .onAppear({
                    =>
                    this.P1_angle = -10.0
                    this.P1_width = 62
                    this.P1_height = 63
                })
                .animationEnd()

                Image(@r(app.media.enemy))
                .animationStart(animateOpt)
                .position(x: P2_PosX, y: P2_PosY)
                .height(this.P2_height)
                .width(this.P2_width)
                .objectFit(ImageFit.Fill)
                .rotate(P2_angle)
                .onAppear({
                    =>
                    this.P2_angle = 10.0
                    this.P2_height = 62//62
                    this.P2_width = 63//63
                    })
                .animationEnd()

                Text("Restart")
                .position(x: 350, y: 300)
                .fontSize(50)
                .fontFamily(@r(app.string.ProggyTinySZ))

            }

        }

    }
}