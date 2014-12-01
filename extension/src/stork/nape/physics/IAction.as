/**
 * User: booster
 * Date: 25/11/14
 * Time: 13:43
 */
package stork.nape.physics {
import nape.phys.Body;

public interface IAction {
    function get body():Body
    function set body(value:Body):void

    function get active():Boolean
    function activate(ratio:Number = 1.0):void
    function deactivate():void

    function perform(controller:NapePhysicsControllerNode):void
}
}
