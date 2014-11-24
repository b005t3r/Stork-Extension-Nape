/**
 * User: booster
 * Date: 24/11/14
 * Time: 11:24
 */
package {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import nape.geom.Vec2;

import nape.phys.Body;

import nape.phys.BodyType;
import nape.phys.Material;

import nape.shape.Polygon;
import nape.space.Space;

import nape.util.ShapeDebug;

import starling.display.StorkRoot;

import stork.core.SceneNode;
import stork.event.nape.NapeSpaceEvent;
import stork.game.GameLoopNode;
import stork.nape.NapeSpaceNode;
import stork.nape.debug.NapeDebugDisplayNode;
import stork.nape.debug.NapeDebugDragNode;
import stork.starling.StarlingPlugin;

[SWF(width="800", height="600", backgroundColor="#333333", frameRate="60")]
public class CharacterDemoMain extends Sprite {
    private static const LEFT:uint      = 0x00000001;
    private static const RIGHT:uint     = 0x00000002;
    private static const UP:uint        = 0x00000004;

    private var _character:Body = new Body(BodyType.DYNAMIC);
    private var _characterMoveState:uint = 0;

    private var _characterMoveMaterial:Material = new Material(0, 0, 0);
    private var _characterStopMaterial:Material = new Material(0, 3, 3);

    public function CharacterDemoMain() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(StorkRoot, this));

        var loop:GameLoopNode = new GameLoopNode();
        scene.addNode(loop);

        var space:NapeSpaceNode = new NapeSpaceNode(new Space(Vec2.weak(0, 1200)));
        scene.addNode(space);

        loop.addNode(space.action);

        var debug:NapeDebugDisplayNode = new NapeDebugDisplayNode(new ShapeDebug(stage.stageWidth, stage.stageHeight, 0x00000000));
        scene.addNode(debug);

        debug.debug.drawConstraints = true;
        addChild(debug.debug.display);

        var drag:NapeDebugDragNode = new NapeDebugDragNode();
        scene.addNode(drag);

        drag.mouseDragTarget = stage;

        setUp(space.space);

        scene.start();

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        space.addEventListener(NapeSpaceEvent.PRE_UPDATE, onPreUpdate);
        space.addEventListener(NapeSpaceEvent.POST_UPDATE, onPostUpdate);
    }

    private function onPreUpdate(event:NapeSpaceEvent):void {
        const maxVelocity:Number    = 150;              // pixels / second
        const maxForce:Number       = 25;               // kg * pixel / second^2
        const jumpForce:Number      = -maxForce * 8;    // negative means 'up'

        var currentVelocity:Number  = _character.velocity.x;
        var desiredVelocity:Number  = NaN;

        if(_characterMoveState & LEFT)
            desiredVelocity = -maxVelocity;

        if(_characterMoveState & RIGHT)
            desiredVelocity = maxVelocity;

        if(_characterMoveState & UP) {
            if(Math.abs(_character.velocity.y) < 0.01)
                _character.applyImpulse(Vec2.weak(0, jumpForce));
        }

        // isNaN
        if(desiredVelocity != desiredVelocity) {
            _character.setShapeMaterials(_characterStopMaterial);
            return;
        }

        var deltaVelocity:Number = desiredVelocity - currentVelocity;
        var impulse:Number = _character.mass * deltaVelocity;

        var force:Vec2 = Vec2.weak();
        force.x = Math.max(-maxForce, Math.min(impulse, maxForce)); // f = mv/t; applyImpulse() takes the '/t' part into account

        _character.setShapeMaterials(_characterMoveMaterial);
        _character.applyImpulse(force);
    }

    private function onPostUpdate(event:NapeSpaceEvent):void {
        var velocity:Vec2 = _character.velocity;

        //trace("velocity: [", int(velocity.x * 1000) / 1000.0, ", ", int(velocity.y * 1000) / 1000.0, "]");
    }

    private function onKeyUp(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:     _characterMoveState &= ~LEFT;   break;
            case Keyboard.RIGHT:    _characterMoveState &= ~RIGHT;  break;

            case Keyboard.UP:
            case Keyboard.SPACE:    _characterMoveState &= ~UP;     break;
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:     _characterMoveState |= LEFT;    break;
            case Keyboard.RIGHT:    _characterMoveState |= RIGHT;   break;

            case Keyboard.UP:
            case Keyboard.SPACE:    _characterMoveState |= UP;      break;
        }
    }

    private function setUp(space:Space):void {
        var w:int = stage.stageWidth;
        var h:int = stage.stageHeight;

        // Create a static border around stage.
        var border:Body = new Body(BodyType.STATIC);
        border.shapes.add(new Polygon(Polygon.rect(0, 0, w, -1)));
        border.shapes.add(new Polygon(Polygon.rect(0, h, w, 1)));
        border.shapes.add(new Polygon(Polygon.rect(0, 0, -1, h)));
        border.shapes.add(new Polygon(Polygon.rect(w, 0, 1, h)));
        border.space = space;

        var floor:Body = new Body(BodyType.STATIC);
        floor.shapes.add(new Polygon(Polygon.rect(50, h - 50, w - 100, 1)));

        // stairs
        floor.shapes.add(new Polygon(Polygon.rect(50, h - 250, 50, 200)));
        floor.shapes.add(new Polygon(Polygon.rect(100, h - 200, 50, 150)));
        floor.shapes.add(new Polygon(Polygon.rect(150, h - 150, 50, 100)));
        floor.shapes.add(new Polygon(Polygon.rect(200, h - 100, 50, 50)));

        // obstacle
        floor.shapes.add(new Polygon(Polygon.rect(300, h - 100, 50, 50)));

        // floating platforms
        floor.shapes.add(new Polygon(Polygon.rect(150, h - 300, 150, 50)));
        floor.shapes.add(new Polygon(Polygon.rect(350, h - 350, 150, 50)));

        floor.space = space;

        _character.shapes.add(new Polygon(Polygon.box(16, 32)));
        _character.position.setxy((w / 2), ((h - 50) - 32));
        _character.allowRotation = false;
        _character.setShapeMaterials(_characterStopMaterial);
        _character.space = space;
    }
}
}
