/**
 * User: booster
 * Date: 27/11/14
 * Time: 12:22
 */
package roguelike {
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
        if(body.userData.moveVector.length == 0)
            return;

        var impulse:Vec2 = body.userData.moveVector.mul(_maxImpulse, true);
        body.applyImpulse(impulse);
    }
}
}
