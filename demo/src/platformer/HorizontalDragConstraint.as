/**
 * User: booster
 * Date: 26/11/14
 * Time: 10:41
 */
package platformer {
import nape.geom.Vec2;
import nape.phys.Body;

import stork.nape.physics.Constraint;
import stork.nape.physics.NapePhysicsControllerNode;

public class HorizontalDragConstraint extends Constraint {
    private var _maxDrag:Number;

    public function HorizontalDragConstraint(maxDrag:Number = 30) {
        _maxDrag = maxDrag;
    }

    override public function apply(body:Body, controller:NapePhysicsControllerNode):void {
        var vel:Number = body.velocity.x;

        if(vel == 0)
            return;

        var sign:Number = Math.abs(vel) / vel;

        body.applyImpulse(Vec2.weak(sign * -_maxDrag, 0));

        if(body.velocity.x * vel < 0)
            body.velocity.x = 0;
    }
}
}
