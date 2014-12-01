/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:29
 */
package stork.nape.physics {
import nape.phys.Body;

public class Action implements IAction {
    protected var _body:Body;
    protected var _ratio:Number = 0;

    public function get body():Body { return _body; }
    public function set body(value:Body):void { _body = value; }

    public function get active():Boolean { return _ratio != 0; }

    public function activate(ratio:Number = 1.0):void { _ratio = ratio; }
    public function deactivate():void { _ratio = 0; }

    public function perform(controller:NapePhysicsControllerNode):void {
        // do nothing - implement me!
    }
}
}
