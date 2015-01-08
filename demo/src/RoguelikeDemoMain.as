/**
 * User: booster
 * Date: 26/11/14
 * Time: 17:22
 */
package {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.GameInputEvent;
import flash.events.KeyboardEvent;
import flash.ui.GameInput;
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.ui.Keyboard;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.ShapeDebug;

import roguelike.DragConstraint;
import roguelike.MaxVelocityConstraint;
import roguelike.MoveAction;

import starling.display.StorkRoot;

import stork.core.SceneNode;
import stork.event.nape.NapeSpaceEvent;
import stork.game.GameLoopNode;
import stork.nape.NapeSpaceNode;
import stork.nape.physics.NapePhysicsControllerNode;
import stork.nape.debug.NapeDebugDisplayNode;
import stork.nape.debug.NapeDebugDragNode;
import stork.starling.StarlingPlugin;

[SWF(width="800", height="600", backgroundColor="#333333", frameRate="60")]
public class RoguelikeDemoMain extends Sprite {
    private var _character:Body                                 = new Body(BodyType.DYNAMIC);
    private var _moveAction:MoveAction                          = new MoveAction(20);
    private var _maxVelocityConstraint:MaxVelocityConstraint    = new MaxVelocityConstraint(120);
    private var _dragConstraint:DragConstraint                  = new DragConstraint(10);

    private var _gameInput:GameInput                            = new GameInput();
    private var _ratioModifier:Number                           = 1;

    public function RoguelikeDemoMain() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(StorkRoot, this));

        var loop:GameLoopNode = new GameLoopNode();
        scene.addNode(loop);

        var s:Space = new Space(Vec2.weak(0, 0)); // no gravity, it's a top-down game
        s.worldLinearDrag = 0;

        var space:NapeSpaceNode = new NapeSpaceNode(s);
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

        var bodyController:NapePhysicsControllerNode = new NapePhysicsControllerNode();
        scene.addNode(bodyController);

        bodyController.addAction(_moveAction);
        bodyController.addActiveBody(_character, _moveAction);
        bodyController.addConstraint(_dragConstraint);
        bodyController.addConstraint(_maxVelocityConstraint);

        scene.start();

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

        space.addEventListener(NapeSpaceEvent.POST_UPDATE, onPostUpdate);

        trace("is controller supported: " + GameInput.isSupported);
        trace("number of devices: " + GameInput.numDevices);

        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
        _gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, onDeviceUnusable);
    }

    private function onDeviceAdded(event:GameInputEvent):void {
        var device:GameInputDevice = event.device;

        trace("device added: ", device);

        device.enabled = true;
        var count:int = device.numControls;
        for(var i:int = 0; i < count; ++i) {
            var deviceControl:GameInputControl = device.getControlAt(i);
            deviceControl.addEventListener(Event.CHANGE, onGameInputControlChange);

            trace("control: ", deviceControl.id);
        }
    }

    private function onGameInputControlChange(event:Event):void {
        var deviceControl:GameInputControl = event.target as GameInputControl;
        var value:Number = deviceControl.value;

        //trace(deviceControl.id, ": ", deviceControl.value);

        if(deviceControl.id == "AXIS_1") {
            if(Math.abs(value) < 0.01)
                _character.userData.moveVector.x = 0;
            else
                _character.userData.moveVector.x = value;
        }

        if(deviceControl.id == "AXIS_2") {
            if(Math.abs(value) < 0.01)
                _character.userData.moveVector.y = 0;
            else
                _character.userData.moveVector.y = value;
        }

        if(deviceControl.id == "BUTTON_9") {
            if(value > 0) {
                _ratioModifier = 0.5;
                _maxVelocityConstraint.maxVelocity /= 2;
            }
            else {
                _ratioModifier = 1;
                _maxVelocityConstraint.maxVelocity *= 2;
            }
        }

        if(_character.userData.moveVector.length > 0)
            _character.userData.moveVector.length = _character.userData.moveVector.length * _ratioModifier
    }

    private function onDeviceRemoved(event:GameInputEvent):void {
        trace("device removed: ", event.device);
    }

    private function onDeviceUnusable(event:GameInputEvent):void {
        trace("device unusable: ", event.device);
    }

    private function onPostUpdate(event:NapeSpaceEvent):void {
        var velocity:Vec2 = _character.velocity;

        //trace("velocity: [", int(velocity.x * 1000) / 1000.0, ", ", int(velocity.y * 1000) / 1000.0, "]");
    }

    private function onKeyUp(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:
            case Keyboard.RIGHT:
                _character.userData.moveVector.x = 0;
                break;

            case Keyboard.UP:
            case Keyboard.DOWN:
                _character.userData.moveVector.y = 0;
                break;
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch(event.keyCode) {
            case Keyboard.LEFT:
                _character.userData.moveVector.x = -1;
                break;

            case Keyboard.RIGHT:
                _character.userData.moveVector.x = 1;
                break;

            case Keyboard.UP:
                _character.userData.moveVector.y = -1;
                break;

            case Keyboard.DOWN:
                _character.userData.moveVector.y = 1;
                break;
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

        //border.cbTypes.add(FLOOR);

        var walls:Body = new Body(BodyType.STATIC);
        walls.shapes.add(new Polygon(Polygon.rect(50, 50, 25, 125)));
        walls.shapes.add(new Polygon(Polygon.rect(75, 50, 125, 25)));

        walls.shapes.add(new Polygon(Polygon.rect(100, 100, 25, 75)));
        walls.shapes.add(new Polygon(Polygon.rect(125, 100, 125, 25)));

        walls.space = space;

        //walls.cbTypes.add(FLOOR);

        _character.shapes.add(new Circle(12.5, null, new Material(0, 0, 0)));
        _character.position.setxy(w / 2, h / 2);
        _character.allowRotation = false;
        _character.space = space;
        _character.userData.moveVector = Vec2.get();
        //_character.cbTypes.add(CHARACTER);

        //space.listeners.add(_landingListener);
    }
}
}
