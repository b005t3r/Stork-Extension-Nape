package {

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;

import nape.space.Space;
import nape.util.ShapeDebug;

import starling.display.StorkRoot;

import stork.core.SceneNode;
import stork.game.GameLoopNode;
import stork.nape.NapeSpaceNode;
import stork.nape.debug.NapeDebugDisplayNode;
import stork.nape.debug.NapeDebugDragNode;
import stork.starling.StarlingPlugin;

[SWF(width="800", height="600", backgroundColor="#333333", frameRate="60")]
public class Main extends Sprite {
    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        var scene:SceneNode = new SceneNode();

        scene.registerPlugin(new StarlingPlugin(StorkRoot, this));

        var loop:GameLoopNode = new GameLoopNode();
        scene.addNode(loop);

        var space:NapeSpaceNode = new NapeSpaceNode();
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

        // Create the floor for the simulation.
        //   We use a STATIC type object, and give it a single
        //   Polygon with vertices defined by Polygon.rect utility
        //   whose arguments are (x, y) of top-left corner and the
        //   width and height.
        //
        //   A static object does not rotate, so we don't need to
        //   care that the origin of the Body (0, 0) is not in the
        //   centre of the Body's shapes.
        var floor:Body = new Body(BodyType.STATIC);
        floor.shapes.add(new Polygon(Polygon.rect(50, (h - 50), (w - 100), 1)));
        floor.space = space;

        // Create a tower of boxes.
        //   We use a DYNAMIC type object, and give it a single
        //   Polygon with vertices defined by Polygon.box utility
        //   whose arguments are the width and height of box.
        //
        //   Polygon.box(w, h) === Polygon.rect((-w / 2), (-h / 2), w, h)
        //   which means we get a box whose centre is the body origin (0, 0)
        //   and that when this object rotates about its centre it will
        //   act as expected.
        for (var i:int = 0; i < 16; i++) {
            var box:Body = new Body(BodyType.DYNAMIC);
            box.shapes.add(new Polygon(Polygon.box(16, 32)));
            box.position.setxy((w / 2), ((h - 50) - 32 * (i + 0.5)));
            box.space = space;
        }

        // Create the rolling ball.
        //   We use a DYNAMIC type object, and give it a single
        //   Circle with radius 50px. Unless specified otherwise
        //   in the second optional argument, the circle is always
        //   centered at the origin.
        //
        //   we give it an angular velocity so when it touched
        //   the floor it will begin rolling towards the tower.
        var ball:Body = new Body(BodyType.DYNAMIC);
        ball.shapes.add(new Circle(50));
        ball.position.setxy(50, h / 2);
        ball.angularVel = 10;
        ball.space = space;

        // In each case we have used for adding a Shape to a Body
        //    body.shapes.add(shape);
        // We can also use:
        //    shape.body = body;
        //
        // And for adding the Body to a Space:
        //    body.space = space;
        // We can also use:
        //    space.bodies.add(body);
    }

}
}
