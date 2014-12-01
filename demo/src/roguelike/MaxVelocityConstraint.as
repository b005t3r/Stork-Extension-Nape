/**
 * User: booster
 * Date: 27/11/14
 * Time: 12:33
 */
package roguelike {
import nape.phys.Body;

import stork.nape.physics.Constraint;
import stork.nape.physics.NapePhysicsControllerNode;

public class MaxVelocityConstraint extends Constraint {
    private var _maxVelocity:Number;

    public function MaxVelocityConstraint(maxVelocity:Number = 150) {
        _maxVelocity = maxVelocity;
    }

    public function get maxVelocity():Number { return _maxVelocity; }
    public function set maxVelocity(value:Number):void { _maxVelocity = value; }

    override public function apply(body:Body, controller:NapePhysicsControllerNode):void {
        if(body.velocity.length > _maxVelocity)
            body.velocity.length = _maxVelocity;
    }
}
}
