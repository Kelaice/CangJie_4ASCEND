package ohos_app_cangjie_entry.game_body

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.sync.*
import ohos.font.*
import std.time.*
import std.collection.ArrayList
import std.random.Random

type ObservedMatrix = ObservedArray<Int64>

type OpacityMatrix = ObservedArray<Float64>

//棋盘绘制组件
@Component
public class chessGrid {
    @State
    var opc: Float64 = 0.0

    func build() {
        Grid {
            ForEach(
                Array<Int64>(81, {_ => 0}),
                itemGeneratorFunc: {
                    entity: Int64, index: Int64 => GridItem {
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
            .opacity(opc)
            .onAppear(
                {
                    => animateTo(
                        AnimateParam(
                            duration: 300,
                            curve: Curve.Linear,
                            delay: 0,
                            iterations: 1, // 设置-1表示动画无限循环
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                =>
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        ),
                        {
                            => opc = 1.0
                        }
                    )
                })
    }
}

@Component
public class testboard {
    @Link
    var data: ObservedMatrix
    @Link
    var game: FourAscendGame
    @Link
    var game_state: Board
    @Link
    var player: Int64
    @Link
    var step: Int64
    @Link
    var AI: StupidFourAscendPlayer
    @Link
    var opacityArray: OpacityMatrix
    @Link
    var wp: ObservedArrayList<Array<Int64>>
    @Link
    var bp: ObservedArrayList<Array<Int64>>
    @Link
    var animateFlag: Bool
    @Link
    var unopposed: Bool

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

    private func changeOpacity(ascend_state: Array<Array<Int64>>) {
        for (i in 0..9) {
            for (j in 0..9) {
                if (data[i * 9 + j] == 0 && this.game_state[2][i][j] == 1) {
                    this.opacityArray[i * 9 + j] = 0.8 - 0.5 * Float64(ascend_state[i][j])
                } else if (data[i * 9 + j] == 0 && this.game_state[2][i][j] == -1) {
                    this.opacityArray[i * 9 + j] = 0.8 + 0.5 * Float64(ascend_state[i][j])
                }
            }
        }
    }

    private func JudgeAscendState() {
        for (i in 0..9) {
            for (j in 0..9) {
                if (data[i * 9 + j] == 0 && this.game_state[2][i][j] == 1) {
                    return false
                } else if (data[i * 9 + j] == 0 && this.game_state[2][i][j] == -1) {
                    return false
                }
            }
        }
        return true
    }

    private func InitOpacitArray() {
        for (i in 0..81) {
            this.opacityArray[i] = 0.8
        }
    }

    public func AddAscendChess() {
    }

    func build() {
        Stack {
            Grid {
                ForEach(
                    data,
                    itemGeneratorFunc: {
                        entity: Int64, index: Int64 => GridItem {

                            //显示魔法白子
                            if (data[index] == 1 && this.game_state[1][index / 9][index % 9] == 1) {
                                Image(@r(app.media.White_Chess_Plant)).height(30.0).width(30.0)
                            } else if (data[index] == 0 && this.game_state[1][index / 9][index % 9] == 1 &&
                                this.game_state[2][index / 9][index % 9] == 1) {
                                Image(@r(app.media.White_Chess_Plant))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        => changeOpacity(this.game_state[2])
                                    })
                                    .animationEnd()
                            } //显示魔法黑子
                                else if (data[index] == -1 && this.game_state[1][index / 9][index % 9] == 1) {
                                Image(@r(app.media.Black_Chess_Plant)).height(30.0).width(30.0)
                            } else if (data[index] == 0 && this.game_state[1][index / 9][index % 9] == 1 &&
                                this.game_state[2][index / 9][index % 9] == -1) {
                                Image(@r(app.media.Black_Chess_Plant))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        => changeOpacity(this.game_state[2])
                                    })
                                    .animationEnd()
                            }
                                //显示白子
                                else if (data[index] == 1) {
                                Image(@r(app.media.white_Chess)).height(30.0).width(30.0)
                            } else if (data[index] == 0 && this.game_state[2][index / 9][index % 9] == 1) {
                                Image(@r(app.media.white_Chess))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        => changeOpacity(this.game_state[2])
                                    })
                                    .animationEnd()
                            }
                                //显示黑子
                                else if (data[index] == -1) {
                                Image(@r(app.media.black_Chess)).height(30.0).width(30.0)
                            } else if (data[index] == 0 && this.game_state[2][index / 9][index % 9] == -1) {
                                Image(@r(app.media.black_Chess))
                                    .animationStart(animateOpt)
                                    .height(30.0)
                                    .width(30.0)
                                    .opacity(opacityArray[index])
                                    .onAppear({
                                        => changeOpacity(this.game_state[2])
                                    })
                                    .animationEnd()
                            }

                            //显示魔法植物
                            if (game_state[1][index / 9][index % 9] == 1 && data[index] == 0 &&
                                game_state[2][index / 9][index % 9] == 0) {
                                Rect(width: 10, height: 10).foregroundColor(0xf7e200)
                            }
                        }
                            .height(40)
                            .width(40)
                            .onClick(
                                {
                                    evt =>
                                    if (data[index] == 0) {
                                        var back: (Int64, Int64, Board) = run(this.data, this.game, this.game_state,
                                            index, this.player, this.step)
                                        this.step = back[0]
                                        this.player = back[1]
                                        this.game_state = back[2]
                                        this.game.hp1 = game_state[3]
                                        this.game.hp2 = game_state[4]

                                        this.animateFlag = this.game.animateFlag
                                        this.unopposed = this.game.unopposed

                                        if (this.animateFlag) {
                                            this.wp = this.game.wp
                                            this.bp = this.game.bp
                                            if (step == 2) {
                                                this.game.wp = ObservedArrayList(ArrayList())
                                                this.game.bp = ObservedArrayList(ArrayList())
                                            }
                                        }
                                        if (step == 2) {
                                            this.game.animateFlag = false
                                            this.game.unopposed = false
                                        }
                                    }
                                    if (step == 3 && this.player == -1) {
                                        var ai_move = ai_move(this.AI, this.game_state)
                                        var back: (Int64, Int64, Board) = run(this.data, this.game, this.game_state,
                                            ai_move, this.player, this.step)
                                        this.step = back[0]
                                        this.player = back[1]
                                        this.game_state = back[2]
                                        this.game.hp1 = game_state[3]
                                        this.game.hp2 = game_state[4]

                                        this.animateFlag = this.game.animateFlag
                                        this.unopposed = this.game.unopposed

                                        if (this.animateFlag) {
                                            this.wp = this.game.wp
                                            this.bp = this.game.bp
                                            this.game.wp = ObservedArrayList(ArrayList())
                                            this.game.bp = ObservedArrayList(ArrayList())
                                        }
                                        this.game.animateFlag = false
                                        this.game.unopposed = false
                                    }
                                    if (JudgeAscendState()) {
                                        InitOpacitArray()
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
    @Prop
    var game_state: Board

    var y_pos: Int64 = 180
    var x_pos: Int64 = 100

    @State
    var player_posX: Int64 = 90
    @State
    var player_posY: Int64 = 100
    @State
    var player_angel: Float32 = 0.0
    @State
    var enemy_posX: Int64 = 690
    @State
    var enemy_posY: Int64 = 102
    @State
    var enemy_angel: Float32 = 0.0

    @State
    var opc = 0.0

    @State
    var hp1: Int64 = 6
    @State
    var hp2: Int64 = 6
    @State
    var player_flash_opa = 0.0
    @State
    var enemy_flash_opa = 0.0
    @State
    var player_flash = false
    @State
    var enemy_flash = false
    @Link
    var onHit: Bool
    @Link
    var step: Int64

    private func HP1_HitJudge() {
        if (onHit && game_state[3] != hp1) {
            hp1 = game_state[3]
            player_flash = true
            player_flash_opa = 1.0
        }
        return hp1
    }

    private func HP2_HitJudge() {
        if (onHit && game_state[4] != hp2) {
            hp2 = game_state[4]
            enemy_flash = true
            enemy_flash_opa = 1.0
        }
        return hp2
    }

    private func build() {
        Column {
            Stack {
                Image(@r(app.media.player)).height(62).width(63).objectFit(ImageFit.Contain)

                Image(@r(app.media.player_onHit))
                    .animationStart(
                        AnimateParam(
                            duration: 50,
                            curve: Curve.Linear,
                            delay: 0,
                            iterations: 1,
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                =>
                                this.player_flash_opa = 0.0
                                this.player_flash = false
                                if (hp1 <= 0 || hp2 <= 0) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 1000,
                                            curve: Curve.EaseOut,
                                            delay: 0,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                =>
                                                this.step = 4
                                                this.player_posX = 90
                                                this.player_posY = 100
                                                this.player_angel = 0.0
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            =>
                                            this.player_posX = -200
                                            this.player_posY = 0
                                            this.player_angel = -720.0
                                        }
                                    )
                                }
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        )
                    )
                    .height(62)
                    .width(63)
                    .objectFit(ImageFit.Contain)
                    .opacity(player_flash_opa)
                    .animationEnd()
            }.position(x: player_posX, y: player_posY).height(62).width(63).rotate(player_angel)

            Image(@r(app.media.HP_Image)).position(x: x_pos, y: y_pos).height(37).width(40)

            Text("${HP1_HitJudge()}")
                .animationStart(
                    AnimateParam(
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1,
                        playMode: PlayMode.Alternate,
                        onFinish: {
                            => this.onHit = false
                        },
                        expectedFrameRateRange: ExpectedFrameRateRange(
                            min: 20,
                            max: 120,
                            expected: 90
                        )
                    )
                )
                .textAlign(TextAlign.Center)
                .fontSize(60)
                .fontColor(0xfc037f)
                .position(x: x_pos + 10, y: y_pos + 50)
                .height(50)
                .fontFamily(@r(app.string.ProggyTinySZ))
                .animationEnd()

            Stack {
                Image(@r(app.media.enemy)).height(62).width(63).objectFit(ImageFit.Contain)

                Image(@r(app.media.enemy_onHit))
                    .animationStart(
                        AnimateParam(
                            duration: 50,
                            curve: Curve.Linear,
                            delay: 0,
                            iterations: 1,
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                =>
                                this.enemy_flash_opa = 0.0
                                this.enemy_flash = false
                                if (hp1 <= 0 || hp2 <= 0) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 1000,
                                            curve: Curve.EaseOut,
                                            delay: 100,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                =>
                                                this.step = 4
                                                this.enemy_posX = 690
                                                this.enemy_posY = 102
                                                this.enemy_angel = 0.0
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            =>
                                            this.enemy_posX = 900
                                            this.enemy_posY = 0
                                            this.enemy_angel = 720.0
                                        }
                                    )
                                }
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        )
                    )
                    .height(62)
                    .width(63)
                    .objectFit(ImageFit.Contain)
                    .opacity(enemy_flash_opa)
                    .animationEnd()
            }.position(x: enemy_posX, y: enemy_posY).height(62).width(63).rotate(enemy_angel)

            Image(@r(app.media.HP_Image)).position(x: x_pos + 600, y: y_pos).height(37).width(40)

            Text("${HP2_HitJudge()}")
                .animationStart(
                    AnimateParam(
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1,
                        playMode: PlayMode.Alternate,
                        onFinish: {
                            => this.onHit = false
                        },
                        expectedFrameRateRange: ExpectedFrameRateRange(
                            min: 20,
                            max: 120,
                            expected: 90
                        )
                    )
                )
                .textAlign(TextAlign.Center)
                .fontSize(60)
                .fontColor(0xfc037f)
                .position(x: x_pos + 600 + 10, y: y_pos + 50)
                .height(50)
                .fontFamily(@r(app.string.ProggyTinySZ))
                .animationEnd()
        }
            .opacity(opc)
            .onAppear(
                {
                    => animateTo(
                        AnimateParam(
                            duration: 300,
                            curve: Curve.Linear,
                            delay: 100,
                            iterations: 1, // 设置-1表示动画无限循环
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                =>
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        ),
                        {
                            => opc = 1.0
                        }
                    )
                })
    }
}

//标题页绘制组件
@Component
public class WelcomePage {
    @Link
    var step: Int64

    @State
    var WelFontOpacity: Float64 = 0.8
    @State
    var WelOpacity: Float64 = 1.0

    let animateOpt = AnimateParam(
        duration: 300,
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

    func build() {
        Stack {
            Image(@r(app.media.titleBackground)).height(400).width(860).position(x: 0, y: 0)

            Text("Touch Screen To Start.")
                .fontSize(50)
                .position(x: 200, y: 300)
                .height(35)
                .width(450)
                .opacity(this.WelFontOpacity)
                .fontFamily(@r(app.string.ProggyTinySZ))
                .onAppear(
                    {
                        => animateTo(
                            AnimateParam(
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
                            ),
                            {
                                => this.WelFontOpacity = 0.3
                            }
                        )
                    })
        }
            .onClick(
                {
                    evt => animateTo(
                        AnimateParam(
                            duration: 600,
                            curve: Curve.Linear,
                            delay: 0,
                            iterations: 1, // 设置-1表示动画无限循环
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                => step = 1
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        ),
                        {
                            => this.WelOpacity = 0.0
                        }
                    )
                })
            .opacity(WelOpacity)
    }
}

//菜单页绘制组件
@Component
public class MenuPage {
    var MenuFlag: Bool = true
    @Link
    var step: Int64
    @Link
    var pre_step: Int64

    @State
    var MenuOpacity: Float64 = 0.0
    @State
    var PVP_Opacity: Float64 = 0.0
    @State
    var PVE_Opacity: Float64 = 1.0
    @State
    var Learn_Opacity: Float64 = 0.0

    @State
    var PVP_Button_X: Int64 = 325
    @State
    var PVP_Button_Y: Int64 = 150
    @State
    var Learn_Button_X: Int64 = 325
    @State
    var Learn_Button_Y: Int64 = 150

    public func build() {
        Stack {
            Image(@r(app.media.background4)).height(400).width(860).position(x: 0, y: -5)

            Image(@r(app.media.Menu_border)).height(400).width(860).position(x: 0, y: -5)

            Image(@r(app.media.Menu_Button_PVP))
                .height(86)
                .width(203)
                .position(x: PVP_Button_X, y: PVP_Button_Y)
                .objectFit(ImageFit.Contain)
                .opacity(this.PVP_Opacity)
                .onClick(
                    {
                        evt => animateTo(
                            AnimateParam(
                                duration: 300,
                                curve: Curve.Linear,
                                delay: 0,
                                iterations: 3, // 设置-1表示动画无限循环
                                playMode: PlayMode.Alternate,
                                onFinish: {
                                    =>
                                    this.pre_step = 2
                                    this.step = 2
                                    PVP_Button_X = 325
                                    PVP_Button_Y = 150
                                    Learn_Button_X = 325
                                    Learn_Button_Y = 150
                                },
                                expectedFrameRateRange: ExpectedFrameRateRange(
                                    min: 20,
                                    max: 120,
                                    expected: 90
                                )
                            ),
                            {=> PVP_Opacity = 0.3}
                        )
                    })

            Image(@r(app.media.Menu_Button_Learn))
                .height(86)
                .width(203)
                .position(x: Learn_Button_X, y: Learn_Button_Y)
                .objectFit(ImageFit.Contain)
                .opacity(this.Learn_Opacity)
                .onClick(
                    {
                        evt => animateTo(
                            AnimateParam(
                                duration: 300,
                                curve: Curve.Linear,
                                delay: 0,
                                iterations: 3, // 设置-1表示动画无限循环
                                playMode: PlayMode.Alternate,
                                onFinish: {
                                    =>
                                    this.step = 5
                                    PVP_Button_X = 325
                                    PVP_Button_Y = 150
                                    Learn_Button_X = 325
                                    Learn_Button_Y = 150
                                },
                                expectedFrameRateRange: ExpectedFrameRateRange(
                                    min: 20,
                                    max: 120,
                                    expected: 90
                                )
                            ),
                            {=> this.Learn_Opacity = 0.3}
                        )
                    })

            Image(@r(app.media.Menu_Button_PVE))
                .height(86)
                .width(203)
                .position(x: 325, y: 150)
                .objectFit(ImageFit.Contain)
                .opacity(this.PVE_Opacity)
                .onClick(
                    {
                        evt => animateTo(
                            AnimateParam(
                                duration: 300,
                                curve: Curve.Linear,
                                delay: 0,
                                iterations: 3, // 设置-1表示动画无限循环
                                playMode: PlayMode.Alternate,
                                onFinish: {
                                    =>
                                    this.pre_step = 3
                                    this.step = 3
                                    PVP_Button_X = 325
                                    PVP_Button_Y = 150
                                    Learn_Button_X = 325
                                    Learn_Button_Y = 150
                                },
                                expectedFrameRateRange: ExpectedFrameRateRange(
                                    min: 20,
                                    max: 120,
                                    expected: 90
                                )
                            ),
                            {=> this.PVE_Opacity = 0.3}
                        )
                    })
        }
            .opacity(this.MenuOpacity)
            .onAppear(
                {
                    => animateTo(
                        AnimateParam(
                            duration: 300,
                            curve: Curve.EaseIn,
                            delay: 0,
                            iterations: 1, // 设置-1表示动画无限循环
                            playMode: PlayMode.Alternate,
                            onFinish: {
                                => animateTo(
                                    AnimateParam(
                                        duration: 300,
                                        curve: Curve.EaseIn,
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
                                    ),
                                    {
                                        =>
                                        PVP_Opacity = 1.0
                                        Learn_Opacity = 1.0
                                        PVP_Button_X = 150
                                        PVP_Button_Y = 50
                                        Learn_Button_X = 500
                                        Learn_Button_Y = 250
                                    }
                                )
                            },
                            expectedFrameRateRange: ExpectedFrameRateRange(
                                min: 20,
                                max: 120,
                                expected: 90
                            )
                        ),
                        {
                            => this.MenuOpacity = 1.0
                        }
                    )
                })
    }
}

//结束页绘制组件
@Component
public class GameEndPage {
    @Link
    var game: FourAscendGame
    @Link
    var game_state: Board
    @Link
    var data: ObservedMatrix
    @Link
    var ai: StupidFourAscendPlayer
    @Link
    var step: Int64
    @Link
    var WhiteAttackPos: ObservedArrayList<Array<Int64>>
    @Link
    var BlackAttackPos: ObservedArrayList<Array<Int64>>
    @Link
    var animateFlag: Bool
    @Link
    var player: Int64
    @Link
    var backto: Int64

    @State
    var P1_angle: Float32 = 10.0
    @State
    var P1_height: Int64 = 40
    @State
    var P1_width: Int64 = 80

    @State
    var P2_angle: Float32 = -10.0
    @State
    var P2_height: Int64 = 40
    @State
    var P2_width: Int64 = 80

    var P1_PosX: Int64 = 230
    var P1_PosY: Int64 = 150

    var P2_PosX: Int64 = 580
    var P2_PosY: Int64 = 150

    @State
    var opa = 0.0

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

    func build() {
        Stack {
            if (step == 4) {
                Image(@r(app.media.Game_End_Image)).height(400).width(860).position(x: 0, y: 0)
                if (game.hp1 > 0) {
                    Text("P1 Wins !").position(x: 300, y: 50).fontSize(80).fontFamily(@r(app.string.ProggyTinySZ))
                } else {
                    Text("P2 Wins !").position(x: 300, y: 50).fontSize(80).fontFamily(@r(app.string.ProggyTinySZ))
                }

                Image(@r(app.media.player))
                    .animationStart(animateOpt)
                    .position(x: P1_PosX, y: P1_PosY)
                    .height(P1_height)
                    .width(P1_width)
                    .objectFit(ImageFit.Fill)
                    .rotate(P1_angle)
                    .onAppear(
                        {
                            =>
                            this.P1_angle = -10.0
                            this.P1_width = 62
                            this.P1_height = 63
                        }
                    )
                    .animationEnd()

                Image(@r(app.media.enemy))
                    .animationStart(animateOpt)
                    .position(x: P2_PosX, y: P2_PosY)
                    .height(this.P2_height)
                    .width(this.P2_width)
                    .objectFit(ImageFit.Fill)
                    .rotate(P2_angle)
                    .onAppear(
                        {
                            =>
                            this.P2_angle = 10.0
                            this.P2_height = 62 //62
                            this.P2_width = 63 //63
                        }
                    )
                    .animationEnd()

                Text("Restart")
                    .position(x: 350, y: 300)
                    .fontSize(50)
                    .fontFamily(@r(app.string.ProggyTinySZ))
                    .onClick(
                        {
                            evt =>
                            game = FourAscendGame(9, 6, 6)
                            ai = StupidFourAscendPlayer(game)
                            this.game_state = game.getInitBoard()
                            this.data = ObservedArray<Int64>(Array<Int64>(81, {_ => 0}))
                            this.step = this.backto
                            this.WhiteAttackPos = ObservedArrayList(ArrayList())
                            this.BlackAttackPos = ObservedArrayList(ArrayList())
                            this.animateFlag = false
                            this.player = 1
                        }
                    )
            }
        }
            .opacity(opa)
            .onAppear {
                animateTo(
                    AnimateParam(
                        duration: 800,
                        curve: Curve.Smooth,
                        delay: 0,
                        iterations: 1,
                        playMode: PlayMode.Alternate,
                        onFinish: {
                            =>
                        },
                        expectedFrameRateRange: ExpectedFrameRateRange(
                            min: 20,
                            max: 120,
                            expected: 90
                        )
                    ),
                    {
                        => this.opa = 1.0
                    }
                )
            }
    }
}

//教学页面绘制组件
@Component
public class teachpage {
    @Link
    var step :Int64
    @State
    var teach_page :Int64 = 1

    var fontsize :Int64 = 25
    var posX :Int64 = 230
    var posY :Int64 = 20

    func build() {
        Stack{

            if(teach_page == 1) {
                Text("欢迎来到4ASCEND！\n这是一个新手教学\n点击屏幕以进入下一页")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: 295, y: 140)
            }
            else if(teach_page == 2) {
                Image(@r(app.media.teach1))
                .height(360)
                .width(360)
                .position(x: 250, y: 10)

                Text("屏幕上的是一个9x9的棋盘\n点击屏幕，白黑双方轮流落子\n(现在不可以哦)")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: 250, y: 20)
            }
            else if(teach_page == 3) {
                Image(@r(app.media.teach2))
                .height(360)
                .width(360)
                .position(x: 250, y: 10)

                Text("4个及以上的棋子连成一线时，\n棋子将进入ASCEND状态\n此时，该名玩家进入攻击阶段")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: posX, y: posY)
            }
            else if(teach_page == 4) {
                Image(@r(app.media.teach3))
                .height(350)
                .width(740)
                .position(x: 60, y: 10)

                Text("下一名玩家自动进入防御状态\n落子之后，双方进行战斗，结算血量\n玩家的状态在两侧显示")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: posX -10, y: posY)
            }
            else if(teach_page == 5) {
                Image(@r(app.media.teach4))
                .height(348)
                .width(738)
                .position(x: 60, y: 10)

                Text("防御玩家可以占据攻击玩家的升华棋子\n这会使得这枚棋子不参与攻击力计算")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: posX -20, y: posY)
            }
            else if(teach_page == 6) {
                Image(@r(app.media.teach5))
                .height(350)
                .width(740)
                .position(x: 60, y: 10)

                Text("棋盘上会随机生成金色的魔法植物\n占据了该位置的棋子，攻击力/防御力+1")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: posX -20, y: posY)
            }
            else if(teach_page == 7) {
                Image(@r(app.media.teach6))
                .height(350)
                .width(740)
                .position(x: 60, y: 10)

                Text("把对方的血量降到零吧！\n棋盘满时，棋子多的一方也将获胜")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: posX, y: 150)
            }
            else if(teach_page == 8) {
                Text("现在点击左上方按钮返回，\n开始你的4ASCEND战斗吧！")
                .fontFamily(@r(app.string.pixelfont))
                .textAlign(TextAlign.Center)
                .fontSize(fontsize)
                .position(x: 270, y: 150)
            }

            Rect(height: 5000, width:5000)
            .opacity(0)
            .onClick({evt=> if(teach_page<8){teach_page++}})

        }
    }
}

//返回按钮绘制组件
@Component
public class backarrow {
    @Link
    var game: FourAscendGame
    @Link
    var game_state: Board
    @Link
    var data: ObservedMatrix
    @Link
    var ai: StupidFourAscendPlayer
    @Link
    var step: Int64
    @Link
    var WhiteAttackPos: ObservedArrayList<Array<Int64>>
    @Link
    var BlackAttackPos: ObservedArrayList<Array<Int64>>
    @Link
    var animateFlag: Bool
    @Link
    var player: Int64

    func build() {
        Image(@r(app.media.backarrow))
            .height(45)
            .width(50)
            .position(x: -100, y: 30)
            .onClick(
                {
                    evt =>
                    game = FourAscendGame(9, 6, 6)
                    ai = StupidFourAscendPlayer(game)
                    this.game_state = game.getInitBoard()
                    this.data = ObservedArray<Int64>(Array<Int64>(81, {_ => 0}))
                    this.step = 1
                    this.WhiteAttackPos = ObservedArrayList(ArrayList())
                    this.BlackAttackPos = ObservedArrayList(ArrayList())
                    this.animateFlag = false
                    this.player = 1
                }
            )
    }
}

//棋子动画绘制组件
@Component
public class AttackAnimation {
    @Link
    var wp: ObservedArrayList<Array<Int64>>
    @Link
    var bp: ObservedArrayList<Array<Int64>>

    @State
    var step_W = 0
    @State
    var step_B = 0

    @Link
    var animateFlag: Bool
    @Link
    var unopposed: Bool
    @Link
    var onHit: Bool

    var Minsize: Int64 = 0
    var Maxsize: Int64 = 0

    let animateOpt = AnimateParam(
        duration: 800,
        curve: Curve.Smooth,
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

    private func WhiteAttackCheck(p: Int64): Float64 {
        if ((step_W == 0 && this.animateFlag) || step_W > 0) {
            return 1.0
        } else {
            return 0.0
        }
    }

    private func BlackAttackCheck(p: Int64): Float64 {
        if ((step_B == 0 && this.animateFlag) || step_B > 0) {
            return 1.0
        } else {
            return 0.0
        }
    }

    private func getPosX(x: Int64, player: Int64) {
        let m: Random = Random()
        if (!this.animateFlag) {
            return x * 40 + 85
        } else {
            if (player == 1 && step_W == 1) {
                return 0 + m.nextInt64(100)
            } else if (player == -1 && step_B == 1) {
                return 450 + m.nextInt64(100)
            } else if (step_B == 2 && step_W == 2) {
                return 225
            } else if (step_B == 3 && step_W == 3) {
                if (player == 1) {
                    return 500
                } else {
                    return 0
                }
            } else {
                return x * 40 + 85
            }
        }
    }

    private func getPosY(x: Int64, y: Int64, player: Int64) {
        let m: Random = Random()
        if (!this.animateFlag) {
            return y * 40 + 15
        } else {
            if (player == 1 && step_W == 1) {
                for (i in 0..wp.size) {
                    if (wp[i][0] == y && wp[i][1] == x) {
                        return (50 + 350 / wp.size * i)
                    }
                }
                return (50 + 350 + m.nextInt64(10))
            } else if (player == -1 && step_B == 1) {
                for (i in 0..bp.size) {
                    if (bp[i][0] == y && bp[i][1] == x) {
                        return (50 + 350 / bp.size * i)
                    }
                }
                return (50 + 350 + m.nextInt64(10))
            } else if (step_B == 2 && step_W == 2) {
                if (wp.size == 0 || bp.size == 0) {
                    if (bp.size == 0) {
                        for (i in 0..wp.size) {
                            if (wp[i][0] == y && wp[i][1] == x) {
                                return (50 + 350 / this.Maxsize * (i + this.Minsize))
                            }
                        }
                    } else {
                        for (i in 0..bp.size) {
                            if (bp[i][0] == y && bp[i][1] == x) {
                                return (50 + 350 / this.Maxsize * (i + this.Minsize))
                            }
                        }
                    }
                } else {
                    var min_size = 0
                    var max_size = 0
                    if (wp.size > bp.size) {
                        min_size = bp.size
                        max_size = wp.size
                    } else {
                        min_size = wp.size
                        max_size = bp.size
                    }
                    if (this.Minsize == 0 || this.Maxsize == 0) {
                        this.Minsize = min_size
                        this.Maxsize = max_size
                    }
                    for (i in 0..min_size) {
                        if (player == 1) {
                            if (wp[i][0] == y && wp[i][1] == x) {
                                return ((50 + 350 / wp.size * i + 50 + 350 / bp.size * i) / 2)
                            }
                        } else {
                            if (bp[i][0] == y && bp[i][1] == x) {
                                return ((50 + 350 / wp.size * i + 50 + 350 / bp.size * i) / 2)
                            }
                        }
                    }
                    for (i in min_size..max_size) {
                        if (max_size == wp.size) {
                            if (wp[i][0] == y && wp[i][1] == x) {
                                return (50 + 350 / wp.size * i)
                            }
                        } else {
                            if (bp[i][0] == y && bp[i][1] == x) {
                                return (50 + 350 / bp.size * i)
                            }
                        }
                    }
                }
                return y * 40 + 15
            } else if (step_B == 3 && step_W == 3) {
                return 130
            } else {
                return y * 40 + 15
            }
        }
    }

    //--------------------------------------------这是屎山----------------------------------------------------------------
    func build() {
        Stack {
            ForEach(
                wp,
                itemGeneratorFunc: {
                    entity: Array<Int64>, index: Int64 => Image(@r(app.media.white_Chess))
                        .height(30.0)
                        .width(30.0)
                        .opacity(WhiteAttackCheck(index))
                        .position(x: getPosX(entity[1], 1), y: getPosY(entity[1], entity[0], 1))
                        .onAppear(
                            {
                                => if (this.animateFlag && !unopposed) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 600,
                                            curve: Curve.EaseOut,
                                            delay: 0,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                => animateTo(
                                                    AnimateParam(
                                                        duration: 400,
                                                        curve: Curve.EaseIn,
                                                        delay: 0,
                                                        iterations: 1, // 设置-1表示动画无限循环
                                                        playMode: PlayMode.Alternate,
                                                        onFinish: {
                                                            => animateTo(
                                                                AnimateParam(
                                                                    duration: 100,
                                                                    curve: Curve.Smooth,
                                                                    delay: 0,
                                                                    iterations: 1, // 设置-1表示动画无限循环
                                                                    playMode: PlayMode.Alternate,
                                                                    onFinish: {
                                                                        => if (this.wp.size == this.bp.size) {
                                                                            this.step_B = 0
                                                                            this.step_W = 0
                                                                            this.animateFlag = false
                                                                            this.Minsize = 0
                                                                            this.Maxsize = 0
                                                                        } else {
                                                                            animateTo(
                                                                                AnimateParam(
                                                                                    duration: 400,
                                                                                    curve: Curve.EaseIn,
                                                                                    delay: 0,
                                                                                    iterations: 1, // 设置-1表示动画无限循环
                                                                                    playMode: PlayMode.Alternate,
                                                                                    onFinish: {
                                                                                        =>
                                                                                        this.step_B = 0
                                                                                        this.step_W = 0
                                                                                        this.animateFlag = false
                                                                                        this.wp = ObservedArrayList(
                                                                                            ArrayList())
                                                                                        this.bp = ObservedArrayList(
                                                                                            ArrayList())
                                                                                        this.Minsize = 0
                                                                                        this.Maxsize = 0
                                                                                        this.onHit = true
                                                                                    },
                                                                                    expectedFrameRateRange: ExpectedFrameRateRange(
                                                                                        min: 20,
                                                                                        max: 120,
                                                                                        expected: 90
                                                                                    )
                                                                                ),
                                                                                {
                                                                                    =>
                                                                                    this.step_B = 3
                                                                                    this.step_W = 3
                                                                                }
                                                                            )
                                                                        }
                                                                    },
                                                                    expectedFrameRateRange: ExpectedFrameRateRange(
                                                                        min: 20,
                                                                        max: 120,
                                                                        expected: 90
                                                                    )
                                                                ),
                                                                {
                                                                    => if (this.step_B == 2 && this.step_W == 2) {
                                                                        if (this.wp.size > this.bp.size) {
                                                                            var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(
                                                                                ArrayList())
                                                                            for (i in (this.bp.size)..(this.wp.size)) {
                                                                                temp.append(this.wp[i])
                                                                            }
                                                                            this.wp = temp
                                                                            this.bp = ObservedArrayList(ArrayList())
                                                                        } else {
                                                                            var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(
                                                                                ArrayList())
                                                                            for (i in (this.wp.size)..(this.bp.size)) {
                                                                                temp.append(this.bp[i])
                                                                            }
                                                                            this.bp = temp
                                                                            this.wp = ObservedArrayList(ArrayList())
                                                                        }
                                                                    }
                                                                }
                                                            )
                                                        },
                                                        expectedFrameRateRange: ExpectedFrameRateRange(
                                                            min: 20,
                                                            max: 120,
                                                            expected: 90
                                                        )
                                                    ),
                                                    {
                                                        =>
                                                        this.step_B = 2
                                                        this.step_W = 2
                                                    }
                                                )
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            => if (this.animateFlag && this.step_W < 1) {
                                                this.step_W = 1
                                                if (this.step_B == 0) {
                                                    this.step_B = 1
                                                }
                                            }
                                        }
                                    )
                                } else if (this.animateFlag && unopposed) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 600,
                                            curve: Curve.EaseOut,
                                            delay: 0,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                => animateTo(
                                                    AnimateParam(
                                                        duration: 400,
                                                        curve: Curve.EaseIn,
                                                        delay: 0,
                                                        iterations: 1, // 设置-1表示动画无限循环
                                                        playMode: PlayMode.Alternate,
                                                        onFinish: {
                                                            =>
                                                            this.step_B = 0
                                                            this.step_W = 0
                                                            this.animateFlag = false
                                                            this.wp = ObservedArrayList(ArrayList())
                                                            this.bp = ObservedArrayList(ArrayList())
                                                            this.Minsize = 0
                                                            this.Maxsize = 0
                                                            this.onHit = true
                                                        },
                                                        expectedFrameRateRange: ExpectedFrameRateRange(
                                                            min: 20,
                                                            max: 120,
                                                            expected: 90
                                                        )
                                                    ),
                                                    {
                                                        =>
                                                        this.step_W = 3
                                                        this.step_B = 3
                                                    }
                                                )
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            =>
                                            this.step_W = 1
                                            this.step_B = 1
                                        }
                                    )
                                }
                            })
                }
            )
            ForEach(
                bp,
                itemGeneratorFunc: {
                    entity: Array<Int64>, index: Int64 => Image(@r(app.media.black_Chess))
                        .height(30.0)
                        .width(30.0)
                        .opacity(BlackAttackCheck(index))
                        .position(x: getPosX(entity[1], -1), y: getPosY(entity[1], entity[0], -1))
                        .onAppear(
                            {
                                => if (this.animateFlag && !unopposed) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 600,
                                            curve: Curve.EaseOut,
                                            delay: 0,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                => animateTo(
                                                    AnimateParam(
                                                        duration: 400,
                                                        curve: Curve.EaseIn,
                                                        delay: 0,
                                                        iterations: 1, // 设置-1表示动画无限循环
                                                        playMode: PlayMode.Alternate,
                                                        onFinish: {
                                                            => animateTo(
                                                                AnimateParam(
                                                                    duration: 100,
                                                                    curve: Curve.Smooth,
                                                                    delay: 0,
                                                                    iterations: 1, // 设置-1表示动画无限循环
                                                                    playMode: PlayMode.Alternate,
                                                                    onFinish: {
                                                                        => if (this.wp.size == this.bp.size) {
                                                                            this.step_B = 0
                                                                            this.step_W = 0
                                                                            this.animateFlag = false
                                                                            this.Minsize = 0
                                                                            this.Maxsize = 0
                                                                        } else {
                                                                            animateTo(
                                                                                AnimateParam(
                                                                                    duration: 400,
                                                                                    curve: Curve.EaseIn,
                                                                                    delay: 0,
                                                                                    iterations: 1, // 设置-1表示动画无限循环
                                                                                    playMode: PlayMode.Alternate,
                                                                                    onFinish: {
                                                                                        =>
                                                                                        this.step_B = 0
                                                                                        this.step_W = 0
                                                                                        this.animateFlag = false
                                                                                        this.wp = ObservedArrayList(
                                                                                            ArrayList())
                                                                                        this.bp = ObservedArrayList(
                                                                                            ArrayList())
                                                                                        this.Minsize = 0
                                                                                        this.Maxsize = 0
                                                                                        this.onHit = true
                                                                                    },
                                                                                    expectedFrameRateRange: ExpectedFrameRateRange(
                                                                                        min: 20,
                                                                                        max: 120,
                                                                                        expected: 90
                                                                                    )
                                                                                ),
                                                                                {
                                                                                    =>
                                                                                    this.step_B = 3
                                                                                    this.step_W = 3
                                                                                }
                                                                            )
                                                                        }
                                                                    },
                                                                    expectedFrameRateRange: ExpectedFrameRateRange(
                                                                        min: 20,
                                                                        max: 120,
                                                                        expected: 90
                                                                    )
                                                                ),
                                                                {
                                                                    => if (this.step_B == 2 && this.step_W == 2) {
                                                                        if (this.wp.size > this.bp.size) {
                                                                            var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(
                                                                                ArrayList())
                                                                            for (i in (this.bp.size)..(this.wp.size)) {
                                                                                temp.append(this.wp[i])
                                                                            }
                                                                            this.wp = temp
                                                                            this.bp = ObservedArrayList(ArrayList())
                                                                        } else {
                                                                            var temp: ObservedArrayList<Array<Int64>> = ObservedArrayList(
                                                                                ArrayList())
                                                                            for (i in (this.wp.size)..(this.bp.size)) {
                                                                                temp.append(this.bp[i])
                                                                            }
                                                                            this.bp = temp
                                                                            this.wp = ObservedArrayList(ArrayList())
                                                                        }
                                                                    }
                                                                }
                                                            )
                                                        },
                                                        expectedFrameRateRange: ExpectedFrameRateRange(
                                                            min: 20,
                                                            max: 120,
                                                            expected: 90
                                                        )
                                                    ),
                                                    {
                                                        =>
                                                        this.step_B = 2
                                                        this.step_W = 2
                                                    }
                                                )
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            => if (this.animateFlag && this.step_B < 1) {
                                                this.step_B = 1
                                                if (this.step_W == 0) {
                                                    this.step_W = 1
                                                }
                                            }
                                        }
                                    )
                                } else if (this.animateFlag && unopposed) {
                                    animateTo(
                                        AnimateParam(
                                            duration: 600,
                                            curve: Curve.EaseOut,
                                            delay: 0,
                                            iterations: 1, // 设置-1表示动画无限循环
                                            playMode: PlayMode.Alternate,
                                            onFinish: {
                                                => animateTo(
                                                    AnimateParam(
                                                        duration: 800,
                                                        curve: Curve.Smooth,
                                                        delay: 0,
                                                        iterations: 1, // 设置-1表示动画无限循环
                                                        playMode: PlayMode.Alternate,
                                                        onFinish: {
                                                            =>
                                                            this.step_B = 0
                                                            this.step_W = 0
                                                            this.animateFlag = false
                                                            this.wp = ObservedArrayList(ArrayList())
                                                            this.bp = ObservedArrayList(ArrayList())
                                                            this.Minsize = 0
                                                            this.Maxsize = 0
                                                            this.onHit = true
                                                        },
                                                        expectedFrameRateRange: ExpectedFrameRateRange(
                                                            min: 20,
                                                            max: 120,
                                                            expected: 90
                                                        )
                                                    ),
                                                    {
                                                        =>
                                                        this.step_W = 3
                                                        this.step_B = 3
                                                    }
                                                )
                                            },
                                            expectedFrameRateRange: ExpectedFrameRateRange(
                                                min: 20,
                                                max: 120,
                                                expected: 90
                                            )
                                        ),
                                        {
                                            =>
                                            this.step_W = 1
                                            this.step_B = 1
                                        }
                                    )
                                }
                            })
                }
            )
        }.position(x: 0, y: 0).height(800).width(500)
    }
}

