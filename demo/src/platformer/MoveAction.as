/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:36
 */
package platformer {
import nape.geom.Vec2;

import stork.nape.physics.Action;
import stork.nape.physics.NapePhysicsControllerNode;

public class MoveAction extends Action {
    private var _maxImpulse:Number;

    public function MoveAction(maxImpulse:Number = 30) {
        _maxImpulse = maxImpulse;
    }

    override public function perform(controller:NapePhysicsControllerNode):void {
        _body.applyImpulse(Vec2.weak(_maxImpulse * _ratio, 0));
    }
}
}
