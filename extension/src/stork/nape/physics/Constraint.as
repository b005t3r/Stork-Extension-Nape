/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:29
 */
package stork.nape.physics {
import nape.phys.Body;

public class Constraint implements IConstraint {
    protected var _active:Boolean = true;

    public function get active():Boolean { return _active; }
    public function set active(value:Boolean):void { _active = value; }

    public function apply(body:Body, controller:NapePhysicsControllerNode):void {
        // do nothing - implement me!
    }
}
}
