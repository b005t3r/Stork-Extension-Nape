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
    private static const STEP_DT:Number             = 1.0 / 100.0;

    private var _spaceNode:NapeSpaceNode;
    private var _space:Space;

    private var _preUpdateEventsDispatched:Boolean  = true;
    private var _postUpdateEventsDispatched:Boolean = true;

    private var _leftoverDt:Number;

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

    override protected function actionStarted():void {
        _leftoverDt = 0;
    }

    override protected function actionUpdated(dt:Number):void {
        var totalDt:Number  = _leftoverDt + dt;
        var iterations:int  = int(totalDt / STEP_DT);

        _leftoverDt = totalDt - iterations * STEP_DT;

        for(var i:int = 0; i < iterations; ++i) {
            if(_preUpdateEventsDispatched)
                _spaceNode.nape_internal::dispatchPreUpdateEvent(STEP_DT);

            _space.step(STEP_DT);

            if(_postUpdateEventsDispatched)
                _spaceNode.nape_internal::dispatchPostUpdateEvent(STEP_DT);
        }
    }
}
}
