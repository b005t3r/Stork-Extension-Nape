/**
 * User: booster
 * Date: 19/11/14
 * Time: 16:09
 */
package stork.nape.debug {

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.space.Space;

import stork.core.Node;
import stork.event.nape.NapeSpaceEvent;
import stork.nape.NapeSpaceNode;

public class NapeDebugDragNode extends Node {
    private var _handJoint:PivotJoint;
    private var _handDragX:Number;
    private var _handDragY:Number;

    private var _mouseDragTarget:flash.display.DisplayObject;

    private var _spaceNode:NapeSpaceNode;
    private var _space:Space;

    public function NapeDebugDragNode(name:String = "Node") {
        super(name);
    }

    // TODO: change this to allow passing the referenced path as a parameter
    [LocalReference("@NapeSpaceNode")]
    public function get spaceNode():NapeSpaceNode { return _spaceNode; }
    public function set spaceNode(value:NapeSpaceNode):void {
        if(_spaceNode != null) {
            _space = null;

            _handJoint.space = null;
            _handJoint.body1 = null;
            _handJoint.body2 = null;
            _handJoint = null;

            _spaceNode.removeEventListener(NapeSpaceEvent.PRE_UPDATE, onPreUpdate);
        }

        _spaceNode = value;

        if(_spaceNode != null) {
            _space = _spaceNode.space;

            _handJoint = new PivotJoint(_space.world, null, Vec2.weak(), Vec2.weak());
            _handJoint.space = _space;
            _handJoint.active = false;
            _handJoint.stiff = false;

            _spaceNode.addEventListener(NapeSpaceEvent.PRE_UPDATE, onPreUpdate);
        }
    }

    public function get mouseDragTarget():flash.display.DisplayObject { return _mouseDragTarget; }
    public function set mouseDragTarget(value:flash.display.DisplayObject):void {
        if(_mouseDragTarget != null) {
            _mouseDragTarget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true);
            _mouseDragTarget.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
            _mouseDragTarget.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
        }

        _mouseDragTarget = value;

        if(_mouseDragTarget != null) {
            _mouseDragTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, true);
            _mouseDragTarget.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
            _mouseDragTarget.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
        }
    }

    /* TODO: implement
    public function enableTouchDrag(eventTarget:starling.display.DisplayObject):void {

    }
    */

    private function onMouseDown(event:MouseEvent):void { beginDrag(event.localX, event.localY); }
    private function onMouseUp(event:MouseEvent):void { finishDrag(); }
    private function onMouseMove(event:MouseEvent):void {
        if(! _handJoint.active)
            return;

        _handDragX = event.localX;
        _handDragY = event.localY;
    }

    private function beginDrag(x:Number, y:Number):void {
        // Allocate a Vec2 from object pool.
        var location:Vec2 = Vec2.get(x, y);

        // Determine the set of Body's which are intersecting mouse point.
        // And search for any 'dynamic' type Body to begin dragging.
        var bodies:BodyList = _space.bodiesUnderPoint(location);
        var count:int = bodies.length;
        for (var i:int = 0; i < count; i++) {
            var body:Body = bodies.at(i);

            if (! body.isDynamic())
                continue;

            // Configure hand joint to drag this body.
            //   We initialise the anchor point on this body so that
            //   constraint is satisfied.
            //
            //   The second argument of worldPointToLocal means we get back
            //   a 'weak' Vec2 which will be automatically sent back to object
            //   pool when setting the handJoint's anchor2 property.
            _handJoint.body2 = body;
            _handJoint.anchor2.set(body.worldPointToLocal(location, true));

            // Enable hand joint!
            _handJoint.active = true;

            _handDragX = x;
            _handDragY = y;

            break;
        }

        location.dispose();
    }

    private function finishDrag():void {
        _handJoint.active = false;
    }

    private function onPreUpdate(event:NapeSpaceEvent):void {
        if(_handJoint.active == false)
            return;

        _handJoint.anchor1.setxy(_handDragX, _handDragY);
    }
}
}
