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
    private var _direction:Vec2;

    public function MoveAction(maxImpulse:Number = 30) {
        _maxImpulse = maxImpulse;
    }

    public function get direction():Vec2 { return _direction; }

    override public function set body(value:Body):void {
        if(_body != null) {
            _direction.dispose();
            _direction = null;
        }

        super.body = value;

        if(_body != null) {
            _direction = Vec2.get();
        }
    }

    override public function perform(controller:NapePhysicsControllerNode):void {
        if(_direction.length == 0)
            return;

        var impulse:Vec2 = Vec2.fromPolar(_maxImpulse * _ratio, _direction.angle);
        _body.applyImpulse(impulse);

        impulse.dispose();
    }
}
}
