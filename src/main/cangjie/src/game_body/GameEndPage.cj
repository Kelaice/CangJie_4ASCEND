/**
 * Created on 2025/9/18
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
public class GameEndPage
{
    @Link var hp1 :Int64
    @Link var hp2 :Int64
    @Link var step :Int64

    func build()
    {
        Stack{
            if(step == 3)
            {
                Image(@r(app.media.Game_End_Image))
                .height(400)
                .width(860)
                .position(x: 0, y: 0)
                if(hp1 > 0)
                {
                     Text("P1 Wins!")
                    .position(x: 300, y: 50)
                    .fontSize(50)
                }
                else
                {
                    Text("P2 Wins!")
                    .position(x: 300, y: 50)
                    .fontSize(50)
                }

            }

        }

    }
}