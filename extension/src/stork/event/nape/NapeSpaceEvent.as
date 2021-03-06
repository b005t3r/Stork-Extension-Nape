/**
 * User: booster
 * Date: 19/11/14
 * Time: 13:16
 */
package stork.event.nape {

import stork.event.Event;
import stork.nape.NapeSpaceNode;

public class NapeSpaceEvent extends Event {
    public static const PRE_UPDATE:String   = "preUpdateNapeSpaceEvent";
    public static const POST_UPDATE:String  = "postUpdateNapeSpaceEvent";

    private var _dt:Number;

    public function NapeSpaceEvent(type:String) {
        super(type, false);
    }

    public function get space():NapeSpaceNode { return target as NapeSpaceNode; }
    public function get dt():Number { return _dt; }

    public function resetEvent(dt:Number):NapeSpaceEvent {
        _dt = dt;

        return reset() as NapeSpaceEvent;
    }
}
}
