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
    private var _constraints:List       = new ArrayList();  // list of all constraints acting on all non-excluded bodies
    private var _excludedBodies:List    = new ArrayList();  // list of sets (of bodies)

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

    public function addAction(body:Body, action:IAction):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        if(! _actions.add(action))
            return;

        action.body = body;
    }

    public function removeAction(body:Body, action:IAction):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        if(! _actions.remove(action))
            return;

        action.body = null;
    }

    public function get constraints():List { return _constraints; }

    public function addConstraint(constraint:IConstraint):void {
        _constraints.add(constraint);
        _excludedBodies.add(new HashSet());
    }

    public function removeConstraint(constraint:IConstraint):void {
        var index:int = _constraints.indexOf(constraint);

        _constraints.removeAt(index);
        _excludedBodies.removeAt(index);
    }

    public function addExcludedBody(body:Body, constraint:IConstraint):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _constraints.indexOf(constraint);

        var bodies:Set = _excludedBodies.get(index);
        bodies.add(body.id);
    }

    public function removeExcludedBody(body:Body, constraint:IConstraint):void {
        if(body.space != _space) throw new ArgumentError("body is not a member of this controller's space");

        var index:int = _constraints.indexOf(constraint);

        var bodies:Set = _excludedBodies.get(index);
        bodies.remove(body.id);
    }

    private function onPreUpdate(event:NapeSpaceEvent):void {
        var actionCount:int = _actions.size();
        for(var i:int = 0; i < actionCount; ++i) {
            var action:IAction = _actions.get(i);

            if(! action.active)
                continue;

            action.perform(this);
        }

        var constrainCount:int  = _constraints.size();
        var bodyCount:int       = _space.bodies.length;
        for(var k:int = 0; k < bodyCount; ++k) {
            var body:Body = _space.bodies.at(k);

            if(! body.isDynamic())
                continue;

            for(var j:int = 0; j < constrainCount; ++j) {
                var constraint:IConstraint = _constraints.get(j);

                if(! constraint.active)
                    continue;

                var excluded:Set = _excludedBodies.get(j);

                if(excluded.contains(body.id))
                    continue;

                constraint.apply(body, this);
            }
        }
    }
}
}
