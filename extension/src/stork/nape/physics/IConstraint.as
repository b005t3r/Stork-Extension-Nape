/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:04
 */
package stork.nape.physics {
import nape.phys.Body;

public interface IConstraint {
    function get active():Boolean
    function set active(value:Boolean):void

    function apply(body:Body, controller:NapePhysicsControllerNode):void
}
}
