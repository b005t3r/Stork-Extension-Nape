/**
 * User: booster
 * Date: 25/11/14
 * Time: 15:55
 */
package platformer {
import nape.phys.Material;

public class Materials {
    private static var _characterMaterial:Material = null;

    public static function characterMaterial():Material {
        if(_characterMaterial == null)
            _characterMaterial = new Material(0, 0, 0);

        return _characterMaterial;
    }
}
}
