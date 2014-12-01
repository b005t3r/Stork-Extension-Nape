/**
 * User: booster
 * Date: 17/11/14
 * Time: 16:17
 */
package stork.game.nape {
import nape.space.Space;

import stork.game.*;
import stork.nape.NapeSpaceNode;
import stork.nape.nape_internal;

use namespace nape_internal;

public class NapeActionNode extends GameActionNode {
    private var _spaceNode:NapeSpaceNode;
    private var _space:Space;

    private var _preUpdateEventsDispatched:Boolean  = true;
    private var _postUpdateEventsDispatched:Boolean = true;

    public function NapeActionNode(spaceNode:NapeSpaceNode, name:String = "NapeAction") {
        if(spaceNode != null)   super(spaceNode.actionPriority, name);
        else                    throw new ArgumentError("'spaceNode' cannot be null");

        _spaceNode  = spaceNode;
        _space      = spaceNode.space;
    }

    public function get space():Space { return _space; }

    public function get preUpdateEventsDispatched():Boolean { return _preUpdateEventsDispatched; }
    public function set preUpdateEventsDispatched(value:Boolean):void { _preUpdateEventsDispatched = value; }

    public function get postUpdateEventsDispatched():Boolean { return _postUpdateEventsDispatched; }
    public function set postUpdateEventsDispatched(value:Boolean):void { _postUpdateEventsDispatched = value; }

    override protected function actionUpdated(dt:Number):void {
        if(_preUpdateEventsDispatched)
            _spaceNode.nape_internal::dispatchPreUpdateEvent();

        _space.step(dt);

        if(_postUpdateEventsDispatched)
            _spaceNode.nape_internal::dispatchPostUpdateEvent();
    }
}
}
