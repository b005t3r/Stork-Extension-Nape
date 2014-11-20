/**
 * User: booster
 * Date: 19/11/14
 * Time: 12:30
 */
package stork.nape {
import nape.geom.Vec2;
import nape.space.Space;

import stork.core.Node;
import stork.event.nape.NapeSpaceEvent;
import stork.game.nape.NapeActionNode;

public class NapeSpaceNode extends Node {
    private var _space:Space;
    private var _actionPriority:int;

    private var _action:NapeActionNode;

    private var _preUpdateEvent:NapeSpaceEvent      = new NapeSpaceEvent(NapeSpaceEvent.PRE_UPDATE);
    private var _postUpdateEvent:NapeSpaceEvent     = new NapeSpaceEvent(NapeSpaceEvent.POST_UPDATE);

    public function NapeSpaceNode(space:Space = null, actionPriority:int = int.MAX_VALUE, name:String = "NapeSpace") {
        super(name);

        if(space == null)   _space = new Space(Vec2.weak(0, 600), null);
        else                _space = space;

        _actionPriority = actionPriority;

        _action = new NapeActionNode(this, name + "Action");
    }

    public function get space():Space { return _space; }
    public function get actionPriority():int { return _actionPriority; }

    public function get action():NapeActionNode { return _action; }

    nape_internal function dispatchPreUpdateEvent():void { dispatchEvent(_preUpdateEvent.reset()); }
    nape_internal function dispatchPostUpdateEvent():void { dispatchEvent(_postUpdateEvent.reset()); }
}
}
