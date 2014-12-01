/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:47
 */
package platformer {
import nape.geom.Vec2;
import nape.phys.Body;

import stork.nape.physics.Constraint;
import stork.nape.physics.NapePhysicsControllerNode;

public class MaxVelocityConstraint extends Constraint {
    private var _upVelocity:Number;
    private var _downVelocity:Number;
    private var _leftVelocity:Number;
    private var _rightVelocity:Number;

    public function MaxVelocityConstraint(upVelocity:Number = 500, downVelocity:Number = 500, leftVelocity:Number = 100, rightVelocity:Number = 100) {
        _upVelocity     = upVelocity;
        _downVelocity   = downVelocity;
        _leftVelocity   = leftVelocity;
        _rightVelocity  = rightVelocity;
    }

    public function get upVelocity():Number { return _upVelocity; }
    public function set upVelocity(value:Number):void { _upVelocity = value; }

    public function get downVelocity():Number { return _downVelocity; }
    public function set downVelocity(value:Number):void { _downVelocity = value; }

    public function get leftVelocity():Number { return _leftVelocity; }
    public function set leftVelocity(value:Number):void { _leftVelocity = value; }

    public function get rightVelocity():Number { return _rightVelocity; }
    public function set rightVelocity(value:Number):void { _rightVelocity = value; }

    override public function apply(body:Body, controller:NapePhysicsControllerNode):void {
        var velocity:Vec2 = body.velocity;

        if(velocity.x < 0) {
            if(velocity.x < -_leftVelocity)
                velocity.x = -_leftVelocity;
        }
        else if(velocity.x > 0) {
            if(velocity.x > _rightVelocity)
                velocity.x = _rightVelocity;
        }

        if(velocity.y < 0) {
            if(velocity.y < -_upVelocity)
                velocity.y = -_upVelocity;
        }
        else if(velocity.y > 0) {
            if(velocity.y > _downVelocity)
                velocity.y = _downVelocity;
        }
    }
}
}
