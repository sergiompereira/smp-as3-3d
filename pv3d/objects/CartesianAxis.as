package srg.pv3d.objects
{
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class  CartesianAxis extends DisplayObject3D
	{

		
		public function CartesianAxis(){
	

			var referenceSystem:Lines3D = new Lines3D();
			referenceSystem.addLine(new Line3D(referenceSystem, new LineMaterial(0xFF0000),2, new Vertex3D(), new Vertex3D(300, 0, 0)));
			referenceSystem.addLine(new Line3D(referenceSystem, new LineMaterial(0x00FF00),2, new Vertex3D(), new Vertex3D(0, 300, 0)));
			referenceSystem.addLine(new Line3D(referenceSystem, new LineMaterial(0x0000FF), 2, new Vertex3D(), new Vertex3D(0, 0, 300)));
			this.addChild(referenceSystem);
			
		}
	}
	
}