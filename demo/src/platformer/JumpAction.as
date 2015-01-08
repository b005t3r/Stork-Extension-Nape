/**
 * User: booster
 * Date: 25/11/14
 * Time: 16:23
 */
package platformer {
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.dynamics.CollisionArbiter;
import nape.geom.Vec2;
import nape.phys.Body;

import stork.nape.physics.Action;
import stork.nape.physics.NapePhysicsControllerNode;

public class JumpAction extends Action {
    public static const CHARACTER:CbType    = new CbType();
    public static const FLOOR:CbType        = new CbType();

    private var _maxImpulse:Number;

    private var _landingListener:InteractionListener;
    private var _jumpListener:InteractionListener;

    public function JumpAction(maxImpulse:Number = 100) {
        _maxImpulse = maxImpulse;
    }

    override public function perform(body:Body, controller:NapePhysicsControllerNode):void {
        if(_landingListener == null && _jumpListener == null) {
            _landingListener = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, CHARACTER, FLOOR, onLanded);
            _jumpListener = new InteractionListener(CbEvent.END, InteractionType.COLLISION, CHARACTER, FLOOR, onJumped);

            body.space.listeners.add(_landingListener);

            body.userData.canJump = false;
        }

        if(! body.userData.canJump || body.userData.jumpRatio == 0)
            return;

        body.applyImpulse(Vec2.weak(0, -_maxImpulse));
        body.userData.canJump = false;
    }

    private function onLanded(callback:InteractionCallback):void {
        var body:Body = callback.int1 as Body;

        var count:int = callback.arbiters.length;
        for(var i:int = 0; i < count; ++i) {
            var arbiter:CollisionArbiter = callback.arbiters.at(i) as CollisionArbiter;

            if(arbiter == null)
                continue;

            // if this collision's normal is pointing up, which is -PI/2, it's on the ground
            if(Math.abs(arbiter.normal.angle + Math.PI/2) > 0.1)
                continue;

            //trace("lands");
            body.userData.canJump = true;

            body.space.listeners.remove(_landingListener);
            body.space.listeners.add(_jumpListener);
            break;
        }
    }

    private function onJumped(callback:InteractionCallback):void {
        //trace("jumps");

        var body:Body = callback.int1 as Body;

        body.space.listeners.remove(_jumpListener);
        body.space.listeners.add(_landingListener);
    }
}
}
