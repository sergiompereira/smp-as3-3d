package srg.pv3d.components
{
	
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	
	import org.papervision3d.view.AbstractView;
	import 	org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.ColorMaterial;
	
	import org.papervision3d.events.InteractiveScene3DEvent;
	
	
	import ascb.util.NumberUtilities;
	import srg.math.MathUtils;
	

	/**
	 * Use example:
	 * 		var view:AbstractView = new BasicView();
			var carrossel:Carousel3D = new Carousel3D();
			carrossel.setup(this.stage, view);

			carrossel.addEventListener(Carrossel3D.STOPED, onCarrosselSelected);
			carrossel.addEventListener(Carrossel3D.STARTED, onCarrosselDeselected);
			
			carrossel.init();
			addChild(view);
			view.camera.zoom = 40;
			
			carrossel.initMouseInteraction();
	 */
			
	public class Carousel3D extends EventDispatcher
	{
	
		public static const STOPED:String = "STOPED";
		public static const STARTED:String = "STARTED";
		/* A state in which the carousel can only be restarted from outside */
		public static const LOCKED:String = "LOCKED";
		
		protected var camera:CameraObject3D;
		protected var container:AbstractView;
		protected var carrossel:DisplayObject3D;
				
		protected var numOfItems:uint; // number of Items to put on stage
		protected var radius:uint = 400; // width of carousel
		protected var centerX:Number = 0//stage.stageWidth / 2; // x position of center of carousel
		protected var centerZ:Number = 0//stage.stageHeight / 2; // z position of center of carousel
		
		protected var itemArray:Array = new Array();
		
		protected var colors:Array = new Array(0xff0000, 0x00ff00, 0x0000ff, 0x990000, 0x009900, 0x000099, 0x330000, 0x003300);
		protected var materials:Array;
		protected var materialInteractive:Boolean;
		protected var materialTransparent:Boolean;
		protected var materialAnimated:Boolean;
		protected var materialQuality:String;
		
		protected var materialOverFnc:Function;
		protected var materialOutFnc:Function;
		
		protected var speed:Number = 2; // initial speed of rotation of carousel
		
		protected var cameraAngle:Number = 4/3*Math.PI; 
		protected var cameraRadius:uint = 1100;
		
		protected var selectedItemId:Number = -1;
		protected var cameraAngleFunction:Function = null;
		protected var destinationCameraAngle:Number;
		
		protected var _status:String = STARTED;
		
		protected var _stageWidth:Number;
		protected var _stageHeight:Number;
		protected var _stage:Stage;
		
		
		
		
		public function Carousel3D() {
			
			
		}
		
		public function setup(stage:Stage, containerobj:AbstractView):void 
		{
			_stage = stage;
			
			container = containerobj;
			
			camera = container.camera;
			//it will be pointing by default to (0,0,0)
			//set zoom - default : 40
			camera.zoom = 80;
			camera.z = -cameraRadius;
						
			carrossel = new DisplayObject3D();
			container.scene.addChild(carrossel);
			
			
		}
		
		/**
		 * 
		 * @param	materialsList : an array of arrays. The later ones should be a list of objects with these expected properties: mc,x,y,z;
		 * This structure allows for adding several MovieClips within each item of the corousel. A null value is accepted for testing purposes. A group of colored planes is internaly created in place.
		 * Example: var materials:Array = new Array( 											
											new Array( { mc:myMovieClip1, x: -15, y:10, z:50 }, { mc:myMovieClip2, x:-15, y:5, z:0 } ), 
											new Array( { mc:myMovieClip3, x:0, y:0, z:150 }, { mc:myMovieClip4, x: 0, y:25, z:100 }, { mc:myMovieClip5, x:5, y:30, z:70 }),	
											new Array( { mc:myMovieClip6, x:0, y:0, z:100 })									
										);
			
		 * @param	interactive : wether the items should react to mouse interaction. Reduces performance
		 * @param	transparent : wether the empty areas of the MovieClips should be kept transparent. Reduces performance
		 * @param	animated : wether animations within the MovieClips should be kept. Reduces performance
		 * @param	quality : allowed "low", "medium", "high"
		 * @param	overFnc : callback when mouse rolls over an item. Expect an argument of type int, which contains the item id (the same as the index of the corrisponding item in the materialList array)
		 * @param	outFnc : callback when mouse rolls out an item. Expect an argument of type int, which contains the item id (the same as the index of the corrisponding item in the materialList array)
		 */
		
		public function init(materialsList:Array = null, interactive:Boolean = false, transparent:Boolean = false, animated:Boolean = false, quality:String = "medium", overFnc:Function = null, outFnc:Function = null):void {
			
			materialInteractive = interactive;
			materialTransparent = transparent;
			materialAnimated = animated;
			materialQuality = quality;
			materialOverFnc = overFnc;
			materialOutFnc = outFnc;
			
			if (camera == null) 
			{
				throw new IOError("Carousel3D:init(): containerobj not defined. Call setup() first.");
			}
			else 
			{
				if(materialsList != null){
					materials = materialsList;
				}
				build();
			}
		}
			
			
		protected function build():void 
		{	
			_stageWidth = _stage.stageWidth;
			_stageHeight = _stage.stageHeight;
			
			if(materials == null){
				numOfItems = colors.length;
			}else {
				numOfItems = materials.length;
			}
			
			var angle:Number;
			var plane:Plane;
			for (var i:uint = 0; i < numOfItems; i++) 
			{	
				var itemContainer:DisplayObject3D = new DisplayObject3D();
			
				if(materials == null){
					plane = new Plane(new ColorMaterial(colors[i], 1, false));
					itemContainer.addChild(plane);
				}else {
					for (var j:uint = 0; j < materials[i].length; j++) {
						
						var moviemat:MovieMaterial = new MovieMaterial(materials[i][j].mc, materialTransparent, materialAnimated, false, new Rectangle(0, -(materials[i][j].mc as MovieClip).height, (materials[i][j].mc as MovieClip).width, 2*(materials[i][j].mc as MovieClip).height));
						moviemat.smooth = true;
						moviemat.interactive = materialInteractive;
						moviemat.setQuality(materialQuality, _stage);
						
						plane = new Plane(moviemat);
						plane.x = materials[i][j].x;
						plane.y = materials[i][j].y;
						plane.z = materials[i][j].z;
						
						plane.name = i +"-" + j;
						plane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onObjectRelease);
						
						plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onObjectOver);
						plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onObjectOut);
						
						
						itemContainer.addChild(plane);
					}
				}
				
				angle = i * ((Math.PI * 2) / numOfItems);
				itemArray.push(itemContainer);
			
				itemContainer.x = Math.cos(angle) * radius + centerX; // x position of Item
				itemContainer.z = Math.sin(angle) * radius + centerZ; // y postion of Item
				
				itemContainer.name = i.toString();				
				
				carrossel.addChild(itemContainer);
			}
	
			cameraAngleFunction = setCameraAngleOnAutonomy;
			_stage.addEventListener(Event.ENTER_FRAME, onFrame);
			
			//update now
			onFrame();	
		}
		
		private function onFrame(evt:Event = null):void
		{	
			updateCarrossel();
			cameraAngleFunction();	
			
			if (Math.abs(speed) < 1 && selectedItemId == -1 && Math.abs(getObjectAtFront(false)-getObjectAtFront())<0.2) {
				centerOnSelectedObject(getObjectAtFront());
			}
			container.singleRender();
		}
		
		
		private function updateCarrossel():void 
		{
			camera.y += (MathUtils.Scale(_stage.mouseY, 0, _stageHeight, 0, -70) - camera.y) / 8;	
			camera.x = Math.cos(cameraAngle) * cameraRadius + centerX; // x position of Item
			camera.z = Math.sin(cameraAngle) * cameraRadius + centerZ; // z postion of Item
			
			//camera rotation em radianos = -(cameraAngle + Math.PI / 2)
			camera.rotationY = -(cameraAngle + Math.PI / 2) * 180 / Math.PI;
			
			for (var i:uint = 0; i < numOfItems; i++) 
			{
				//é preferível indexado à rotação da camera:
				(itemArray[i] as DisplayObject3D).rotationY = camera.rotationY;
			}
		}
		
		//called from client, e.g. on stage mouse over
		public function initMouseInteraction():void {
			initMouseMove();
		}
		
		protected function initMouseMove():void 
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			cameraAngleFunction = setCameraAngleOnMouseMove;
		}
		
		public function stop():void {
			removeStageHandlers();
			dispatchEvent(new Event(Carousel3D.STOPED));
		}
		
		public function restart():void
		{
			if (_status != LOCKED) {
				if(materialInteractive){
					setGroupInteractive(selectedItemId, true);
				}
				selectedItemId = -1;
				cameraAngleFunction = setCameraAngleOnMouseMove;
				addStageHandlers();
				dispatchEvent(new Event(Carousel3D.STARTED));
			}
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			speed = (_stage.mouseX - _stageWidth / 2) / 100;
			
		}

		/* SET CAMERA FUNCTIONS */
		private function setCameraAngleOnAutonomy():void {
			cameraAngle += 0.1;
			correctAngleOffset();
		}
		
		private function setCameraAngleOnMouseMove():void {
			cameraAngle += speed * Math.PI / 180;
			correctAngleOffset();
		}
		
		private function setCameraAngleOnSelection():void 
		{	
			cameraAngle += (destinationCameraAngle - cameraAngle) / 2;
			
			//ao centrar no objecto seleccionado, desactiva os handlers 
			if (Math.abs(destinationCameraAngle-cameraAngle) < 0.005) 
			{	
				cameraAngle = destinationCameraAngle;
				updateCarrossel();
				
				_status = STOPED;
				cameraAngleFunction = setCameraAngleOnMouseMove;
				removeStageHandlers();
				
				_stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
				dispatchEvent(new Event(Carousel3D.STOPED));
			}
		}
		
		private function correctAngleOffset():void 
		{	
			cameraAngle %= (Math.PI * 2);
			if (cameraAngle<0) {
				cameraAngle = Math.PI * 2 + cameraAngle;
			}
		}
		/*****/
		
		
		/* MOUSE INTERACTION FUNCTIONS */
		private function onObjectRelease(evt:InteractiveScene3DEvent):void 
		{		
			//devolvem todos o mesmo valor:
			/*
			trace("a trace: "+ evt.displayObject3D.name);
			trace("b trace: "+ evt.target.name);
			trace("c trace: " + view.interactiveSceneManager.currentDisplayObject3D.name);
			*/
			
			var name:String = evt.displayObject3D.name;
			var id:Number = getIdFromName(name);
			centerOnSelectedObject(id);
			
		}
		
		private function onObjectOver(evt:InteractiveScene3DEvent):void 
		{		
			var name:String = evt.displayObject3D.name;
			var id:Number = getIdFromName(name);
			
			materialOverFnc(id);
			
		}
		
		private function onObjectOut(evt:InteractiveScene3DEvent):void 
		{
			var name:String = evt.displayObject3D.name;
			var id:Number = getIdFromName(name);
			
			materialOutFnc(id);
		}
		
		
		private function onStageUp(evt:Event):void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
			this.restart();
		}
		
		/*****/
		
		
		private function centerOnSelectedObject(id:Number):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
			
			if(materialInteractive){
				setGroupInteractive(selectedItemId, true);
				selectedItemId = id;
				setGroupInteractive(id, false);
			}
			
			destinationCameraAngle = (2 * id * Math.PI / numOfItems);
			cameraAngleFunction = setCameraAngleOnSelection;
			
			var diff:Number = (id * 2) / numOfItems - cameraAngle / Math.PI;
				
			if (diff < 0 && Math.abs(diff)>1) {	
				cameraAngle -= Math.PI * 2;
			}else if (diff > 1) {	
				cameraAngle += Math.PI * 2;
			}	
			
			/*
			trace(selectedItemId);
			trace("diff " + diff);
			trace("cameraangle " + cameraAngle / Math.PI)
			*/
		}
		
		private function getObjectAtFront(rounded:Boolean = true):Number 
		{
			var index:Number
			if(rounded){
				index = Math.round(cameraAngle * numOfItems / (2 * Math.PI));
			}else {
				index = cameraAngle * numOfItems / (2 * Math.PI);
			}
			
			if (index > 2) {
				index = 0;
			}
		
			return index;
		}
		
		private function getIdFromName(name:String):Number 
		{
			return  Number(name.substring(0, name.search("-")));
		}
		
		private function setGroupInteractive(id:Number, interactive:Boolean):void 
		{
			//trace("interactive "+id)
			if (id >= 0)
			{
				var container:DisplayObject3D = carrossel.getChildByName(id.toString());
				for (var i:uint = 0; i < materials[id].length; i++)
				{
					container.getChildByName(id.toString() +"-"+ i).material.interactive = interactive;
				}
			}
		}
	
		private function addStageHandlers():void 
		{
			//_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_stage.addEventListener(Event.ENTER_FRAME, onFrame);
		
		}
		
		private function removeStageHandlers():void 
		{
			//_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function getInstance():DisplayObject3D 
		{	
			return carrossel;	
		}
		
		public function get selectedId():Number {
			if (selectedItemId == -1) {
				return getObjectAtFront();
			}
			return selectedItemId;
		}
		
		public function set selectedId(value:Number):void 
		{
			if (value >= numOfItems) {
				value = 0;
			}else if (value<0) {
				value = numOfItems - 1;
			}
			if(materialInteractive){
				setGroupInteractive(selectedItemId, true);
			}
			addStageHandlers();
			centerOnSelectedObject(value);
			
		}
		
		public function get status():String {
			return _status;
		}
		
		
		public function lock():void {
			_status = LOCKED;
			this.stop();
		}
		
		public function unlock():void {
			_status = STARTED;
			this.restart();
		}
		
	
	}
	
}