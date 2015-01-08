/**
 * User: booster
 * Date: 25/11/14
 * Time: 13:43
 */
package stork.nape.physics {
import nape.phys.Body;

public interface IAction {
    function get active():Boolean
    function set active(value:Boolean):void

    function perform(body:Body, controller:NapePhysicsControllerNode):void
}
}
