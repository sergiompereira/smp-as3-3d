package srg.pv3d.objects
{
	import flash.filters.GlowFilter;
	import flash.display.BlendMode;
	
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.materials.shadematerials.PhongMaterial;
	import org.papervision3d.materials.shadematerials.GouraudMaterial;	
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.ColorMaterial;
	
	
	public class  Object3DUtils
	{
		public static function createBasicCube(color:Number = 0x330099,  width:Number = 200, depth:Number = 200, height:Number = 200):Cube
		{
			return new Cube(new MaterialsList( { all:new ColorMaterial(color) } ), width, depth, height);
		}
		
		public static function createLitCube(light:LightObject3D, lightColor:Number = 0xFFFFFF, objColor:Number = 0x330099, width:Number = 200, depth:Number = 200, height:Number = 200):Cube
		{
			var cube:Cube = new Cube(new MaterialsList( { all:new GouraudMaterial(light, lightColor, objColor) } ), width, depth, height);
			cube.blendMode = BlendMode.MULTIPLY;
			cube.filters = [new GlowFilter(cor, 1, 1, 1, 1, 2)];
			return cube;
		}
	}
	
}