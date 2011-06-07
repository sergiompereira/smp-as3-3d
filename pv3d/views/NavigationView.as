package srg.pv3d.views
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import org.papervision3d.objects.DisplayObject3D;
	
	import org.papervision3d.view.BasicView;
	import org.papervision3d.cameras.CameraType;
	import srg.pv3d.objects.CartesianAxis;
	

	public class  NavigationView extends BasicView
	{
		
		private var axis:DisplayObject3D;
		
		private var mouseDown:Boolean = false;
		private var navMode:uint = 0;
		private var ox:Number;
		private var oy:Number;
		private var sx:Number;
		private var sy:Number;

		private var lastXAngle;
		private var lastYAngle;
		private var lastXPos;
		private var lastYPos;
		private var lastZPos;
		
		private var cameraSpeedAngle:Number = 0.3; // Approximately same speed as mouse movement.
		private	var cameraSpeedPosition:Number = -0.8
		
		
		public function NavigationView(width:Number = 600, height:Number = 400, viewAxis:Boolean = false) {
			
			super(width, height,false, true, CameraType.FREE);
			addEventListener(Event.ADDED_TO_STAGE, onStage);
			addEventListener(Event.ENTER_FRAME, onNewFrame);
			
			if (viewAxis) {
				axis = new CartesianAxis();
				scene.addChild(axis);
			}
		}
		
		
		private function onStage(e:Event):void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}
		
		
		private function onPress(e:MouseEvent):void {
			
			mouseDown = true;
			ox = viewport.mouseX;
			oy = viewport.mouseY;
			
			lastXAngle = camera.rotationX;
			lastYAngle = camera.rotationY;
			lastXPos = camera.x;
			lastYPos = camera.y; 
			lastZPos = camera.z;
		}
		private function onRelease(e:MouseEvent):void{
			mouseDown = false;
			navMode = 0;
		}
		
		private function onKey(e:KeyboardEvent):void{
			
			
			switch(e.charCode) {
				//Shift
				case 0:
					navMode = 1;
					break;
				//Space
				case 32:
					navMode = 2;
					break;
				default:
					navMode = 0;
					
			}
		}
		
		private function onNewFrame(e:Event):void {
			trace(navMode)
			if(mouseDown){
				updateCamera();	//handle navigation	
			}
							
		}
		
		//problemas de performance !!
		private function updateCamera():void{
				sx = (viewport.mouseX-ox);
				sy = (viewport.mouseY-oy);
			
				if (navMode == 0) {
					camera.rotationY = cameraSpeedAngle * sx + lastXAngle;
					camera.rotationX = cameraSpeedAngle * sy + lastYAngle;
				}else if(navMode == 1){
					camera.x = cameraSpeedPosition * sx + lastXPos;
					camera.y = cameraSpeedPosition * sy + lastYPos;
				}else if (navMode == 2) {
					camera.z = cameraSpeedPosition * sy + lastZPos;
				}
				
		}
	}
	
}