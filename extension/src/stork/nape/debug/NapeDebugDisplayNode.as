/**
 * User: booster
 * Date: 19/11/14
 * Time: 12:58
 */
package stork.nape.debug {
import nape.space.Space;
import nape.util.Debug;

import stork.core.Node;
import stork.event.nape.NapeSpaceEvent;
import stork.nape.NapeSpaceNode;

public class NapeDebugDisplayNode extends Node {
    private var _debug:Debug;

    private var _spaceNode:NapeSpaceNode;
    private var _space:Space;

    public function NapeDebugDisplayNode(debug:Debug, name:String = "NapeDebugDisplay") {
        if(debug != null)   super(name);
        else                throw new ArgumentError("'debug' cannot be null");

        _debug = debug;
    }

    public function get debug():Debug { return _debug; }

    // TODO: change this to allow passing the referenced path as a parameter
    [LocalReference("@NapeSpaceNode")]
    public function get spaceNode():NapeSpaceNode { return _spaceNode; }
    public function set spaceNode(value:NapeSpaceNode):void {
        if(_spaceNode != null) {
            _space = null;

            _spaceNode.removeEventListener(NapeSpaceEvent.POST_UPDATE, onPostUpdate);
        }

        _spaceNode = value;

        if(_spaceNode != null) {
            _space = _spaceNode.space;

            _spaceNode.addEventListener(NapeSpaceEvent.POST_UPDATE, onPostUpdate);
        }
    }

    private function onPostUpdate(event:NapeSpaceEvent):void {
        _debug.clear();
        _debug.draw(_space);
        _debug.flush();
    }
}
}
