/**
 * User: booster
 * Date: 25/11/14
 * Time: 13:31
 */
package stork.nape.physics {

import medkit.collection.ArrayList;
import medkit.collection.HashSet;
import medkit.collection.List;
import medkit.collection.Set;

import nape.phys.Body;
import nape.space.Space;

import stork.core.Node;
import stork.event.nape.NapeSpaceEvent;
import stork.nape.*;

public class NapePhysicsControllerNode extends Node {
    private var _spaceNode:NapeSpaceNode;
    private var _space:Space;

    private var _actions:List           = new ArrayList();  // list of all actions, each acting on one specific body
    private var _activeBodies:List      = new ArrayList();  // list of sets (of bodies)

    private var _constraints:List       = new ArrayList();  // list of all constraints acting on all non-excluded bodies
    private var _constrainedBodies:List = new ArrayList();  // list of sets (of bodies)

    public function NapePhysicsControllerNode(name:String = "NapePhysicsController") {
        super(name);
    }

    [LocalReference("@NapeSpaceNode")]
    public function get spaceNode():NapeSpaceNode { return _spaceNode; }
    public function set spaceNode(value:NapeSpaceNode):void {
        if(_spaceNode != null) {
            _space = null;

            _spaceNode.removeEventListener(NapeSpaceEvent.PRE_UPDATE, onPreUpdate);
        }

        _spaceNode = value;

        if(_spaceNode != null) {
            _space = _spaceNode.space;

            _spaceNode.addEventListener(NapeSpaceEvent.PRE_UPDATE, onPreUpdate);
        }
    }

    public function get actions():List { return _actions; }

    public function addAction(action:IAction):void {
        _actions.add(action);
        _activeBodies.add(new HashSet());
    }

    public function removeAction(action:IAction):void {
        var index:int = _actions.indexOf(action);

        _actions.removeAt(index);
        _activeBodies.removeAt(index);
    }

    // TODO: add notification handler to IAction
    public function addActiveBody(body:Body, action:IAction):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _actions.indexOf(action);

        if(index < 0) throw new ArgumentError("action: '" + action + "' is not a part of this physics controller");

        var bodies:Set = _activeBodies.get(index);
        bodies.add(body.id);
    }

    public function removeActiveBody(body:Body, action:IAction):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _actions.indexOf(action);

        if(index < 0) throw new ArgumentError("action: '" + action + "' is not a part of this physics controller");

        var bodies:Set = _activeBodies.get(index);
        bodies.remove(body.id);
    }

    public function get constraints():List { return _constraints; }

    public function addConstraint(constraint:IConstraint):void {
        _constraints.add(constraint);
        _constrainedBodies.add(new HashSet());
    }

    public function removeConstraint(constraint:IConstraint):void {
        var index:int = _constraints.indexOf(constraint);

        _constraints.removeAt(index);
        _constrainedBodies.removeAt(index);
    }

    // TODO: add notification handler to IConstraint
    public function addConstrainedBody(body:Body, constraint:IConstraint):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _constraints.indexOf(constraint);

        if(index < 0) throw new ArgumentError("constraint: '" + constraint + "' is not a part of this physics controller");

        var bodies:Set = _constrainedBodies.get(index);
        bodies.add(body.id);
    }

    public function removeConstrainedBody(body:Body, constraint:IConstraint):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _constraints.indexOf(constraint);

        if(index < 0) throw new ArgumentError("constraint: '" + constraint + "' is not a part of this physics controller");

        var bodies:Set = _constrainedBodies.get(index);
        bodies.remove(body.id);
    }

    private function onPreUpdate(event:NapeSpaceEvent):void {
        var totalBodyCount:int = _space.bodies.length;

        var actionCount:int = _actions.size();
        for(var i:int = 0; i < totalBodyCount; ++i) {
            var actionBody:Body = _space.bodies.at(i);

            if(! actionBody.isDynamic())
                continue;

            for(var j:int = 0; j < actionCount; ++j) {
                var action:IAction = _actions.get(j);

                if(! action.active)
                    continue;

                var active:Set = _activeBodies.get(j);

                if(! active.contains(actionBody.id))
                    continue;

                action.perform(actionBody, this);
            }
        }

        var constrainCount:int = _constraints.size();

        for(var k:int = 0; k < totalBodyCount; ++k) {
            var constrainedBody:Body = _space.bodies.at(k);

            if(! constrainedBody.isDynamic())
                continue;

            for(var p:int = 0; p < constrainCount; ++p) {
                var constraint:IConstraint = _constraints.get(p);

                if(! constraint.active)
                    continue;

                var constrained:Set = _constrainedBodies.get(p);

                if(constrained.contains(constrainedBody.id))
                    continue;

                constraint.apply(constrainedBody, this);
            }
        }
    }
}
}
