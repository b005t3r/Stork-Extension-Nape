/**
 * User: booster
 * Date: 27/11/14
 * Time: 9:53
 */
package roguelike {
import nape.geom.Vec2;
import nape.phys.Body;

import stork.nape.physics.Constraint;
import stork.nape.physics.NapePhysicsControllerNode;

public class DragConstraint extends Constraint {
    private var _maxDrag:Number;

    public function DragConstraint(maxDrag:Number = 15) {
        _maxDrag = maxDrag;
    }

    override public function apply(body:Body, controller:NapePhysicsControllerNode):void {
        if(body.velocity.length == 0)
            return;

        var oldVelocity:Vec2    = Vec2.get(body.velocity.x, body.velocity.y);
        var impulse:Vec2        = Vec2.fromPolar(_maxDrag, oldVelocity.angle + Math.PI);

        body.applyImpulse(impulse);

        // if old angle and new angle don't match, it's probably going the other way - stop it
        if(Math.abs(body.velocity.angle - oldVelocity.angle) > 0.1)
            body.velocity.setxy(0, 0);

        oldVelocity.dispose();
        impulse.dispose();
    }
}
}
