package srg.pv3d.shadows {
	
	//import com.everydayflash.pv3d.ShadowCaster;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.scenes.Scene3D;
	
	
	public class ShadowCasterManager
	{
		
		
		private var scene:Scene3D;
		private var object3D:DisplayObject3D;
		//to cast shadows we will need dummy sprite object
		//that we can draw our shadows into using the ShadowCaster object
		private var spr:Sprite;
		//That dummy sprite will then be passed into a moviematerial
		//where we can project our shadows into our 3D scene
		private var sprMaterial:MovieMaterial;
		private var shadowPlane:Plane;
	
		//To cast shadows we will need a light
		//Declare a PointLight3D object
		private var light:PointLight3D;
		//The shadows are drawn using the ShadowCaster object
		//Declare a ShadowCaster object
		private var shadowCaster:ShadowCaster;
		private var timer:Timer = new Timer(30);
		
		private var viewLight:Boolean;
		private var options:ShadowCasterOptions = new ShadowCasterOptions();

		/**
		 * 
		 * @param	scene
		 * @param	object3D
		 * @param	viewLight
		 * @param	lightObject
		 * @param	shadowOptions
		 * 
		 * If you want to cast shadows of multiple objects you can do so by grouping your objects together 
		 * into a single DisplayObject3D object and then use the DisplayObject3D as your model 
		 * to cast a shadow in the castModel method of your ShadowCaster instance.
		 */
		public function ShadowCasterManager(scene:Scene3D, object3D:DisplayObject3D, viewLight:Boolean = false, lightObject:PointLight3D = null, shadowOptions:ShadowCasterOptions = null)
		{
			this.scene = scene;
			this.object3D = object3D;
			this.viewLight = viewLight;
			
			//default;
			options.alpha = 0.6; 
			options.quality = 2; 
			options.blur = 10; 
			options.shadowType = ShadowCaster.SPOTLIGHT;
			
			if (shadowOptions != null) {
				if (shadowOptions.alpha != 0) {
					options.alpha = shadowOptions.alpha;
				}
				if (shadowOptions.blur != 0) {
					options.blur = shadowOptions.blur;
				}
				if (shadowOptions.quality != 0) {
					options.quality = shadowOptions.quality;
				}
				if (shadowOptions.shadowType != "") {
					options.shadowType = shadowOptions.shadowType;
				}
				
			}
			
			
			//Instantiate your dummy sprite
			spr = new Sprite();
			//draw a rectangle into your dummy sprite
			//note that if you don't want your plane to show in the scene
			//but you do want shadows, you can set the alpha of the
			//beginFill method to 0 (shadows will be drawn but the plane color fill will not)
			spr.graphics.beginFill(0xFFFFFF, 0);
			//the larger the "drawRect" shape the better the quality of your shadows
			spr.graphics.drawRect(0, 0, 256, 256);
			//Add the dummy sprite to a MovieMaterial object
			sprMaterial = new MovieMaterial(spr, true, true, true);
			//create a plane and apply your dummy sprite MovieMaterial to it
			shadowPlane = new Plane(sprMaterial, 2000, 2000, 1, 1);
			//rotate and orient your plane so that it is aligned as the floor/ground
			shadowPlane.rotationX = 90;
			
			
			//Instantiate your light object and set the z, y axis up and to the back
			if(lightObject == null){
				light = new PointLight3D(viewLight); 
				//defaults
				light.z = 600; light.y = 300;
			}else {
				light = lightObject;
			}
			
			//Instantiate your shadowCaster object
			//The parameters are as follows
			//ShadowCaster("name", shadow color, blend mode, shadow alpha, [filters]);
			shadowCaster = new ShadowCaster("shadow", 0x000000, BlendMode.MULTIPLY, options.alpha, [new BlurFilter(options.blur, options.blur, options.quality)]);
			//Set the light type (options are SPOTLIGHT and DIRECTIONAL)
			shadowCaster.setType(options.shadowType);
			//Add your shadowPlane and Cylinder to the scene
			this.scene.addChild(shadowPlane);
			this.scene.addChild(object3D);	
						
			timer.addEventListener(TimerEvent.TIMER, onRenderViewport);
			timer.start();
		}
		
		public function getProjectionPlane():Plane {
			return shadowPlane;
		}
		
		public function getLight():PointLight3D {
			return light;
		}
		
		private function onRenderViewport(e:TimerEvent):void
		{
			//the scene should be renderer by the client !!
			
			//the invalidate() method basically clears the previously drawn shadow
			shadowCaster.invalidate();
			
			//the castModel method casts the shadow of an object in your scene
			//castModel parameters are as follows
			//castModel(object to cast shadow from, light, plane to cast the shadow onto
			shadowCaster.castModel(object3D, light, shadowPlane);
			
			
		}
	}
}

