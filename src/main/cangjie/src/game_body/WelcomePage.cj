/**
 * Created on 2025/9/17
 */
package ohos_app_cangjie_entry.game_body

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.sync.*
import ohos.font.*
import std.time.*


@Component
public class WelcomePageFont{
    var timer: ?Timer = None

    @Link var Welopa :Float64
    @Link var step :Int64
    @Link var pre_step :Int64
    @Link var WelAniOpa :Float64
    func build()
    {
        Stack{
            Image(@r(app.media.titleBackground))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            Image(@r(app.media.WelFont))
            .position(x: 200, y: 300)
            .objectFit(ImageFit.Contain)
            .height(35)
            .width(450)
            .opacity(this.Welopa * 0.8)
        }.onClick({
            evt=>
            if (step == 0)
                {
                    step = 1;pre_step = 0
                }

        }).opacity(this.WelAniOpa)
    }
}