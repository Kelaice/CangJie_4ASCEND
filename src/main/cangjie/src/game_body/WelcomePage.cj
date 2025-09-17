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

    @Link var WelFlag :Bool
    @Link var step :Int64
    func BtoV(): Visibility
    {
        if (this.WelFlag)
        {
            return Visible
        }
        else{
            return Hidden
        }
    }


    func build()
    {
        Stack{
            Image(@r(app.media.titleBackground))
            .height(400)
            .width(860)
            .position(x: 0, y: 0)

            Text("Press Any Key To Continue.")
            .position(x: 300, y: 300)
            .fontSize(20)
            .visibility(BtoV())
            .fontColor(0x838383)
        }.onClick({
            evt=> step = 1
        })
    }

}