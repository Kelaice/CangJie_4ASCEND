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
            .position(x: 200, y: 50)
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
                this.step = 2
            })

            Image(@r(app.media.Menu_Button_Learn))
            .height(86)
            .width(203)
            .position(x: 450, y: 250)
            .objectFit(ImageFit.Contain)
            .onClick({
                evt=>
                this.step = 2
            })
        }
    }
}