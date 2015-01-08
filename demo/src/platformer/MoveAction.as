/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:36
 */
package platformer {
import nape.geom.Vec2;
import nape.phys.Body;

import stork.nape.physics.Action;
import stork.nape.physics.NapePhysicsControllerNode;

public class MoveAction extends Action {
    private var _maxImpulse:Number;

    public function MoveAction(maxImpulse:Number = 30) {
        _maxImpulse = maxImpulse;
    }

    override public function perform(body:Body, controller:NapePhysicsControllerNode):void {
        body.applyImpulse(Vec2.weak(_maxImpulse * body.userData.moveRatio, 0));
    }
}
}
