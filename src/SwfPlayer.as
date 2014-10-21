package
{
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	
	public class SwfPlayer extends Sprite
	{
		private var loader:Loader;
		
		public function SwfPlayer()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onApplicationInvoke, false, 0, true);
		}
		
		private function onSwfLoadComplete(evt:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSwfLoadComplete);
			var scale = calculateScale();
			doScale(scale);
		}
		
		private function calculateScale():Object
		{
			var screenWidth = stage.fullScreenWidth;
			var screenHeigh = stage.fullScreenHeight;
			var loaderWidth = loader.content.width;
			var loaderHeigh = loader.content.height;
			
			var scaleW = 1;
			var scaleH = 1;
			if (loaderWidth > screenWidth) {
				scaleW = screenWidth / loaderWidth;
			}
			
			if (loaderHeigh > screenHeigh) {
				scaleH = screenHeigh / loaderHeigh;
			}
			
			if (scaleH < scaleW) {
				return scaleH;
			}
			else {
				return scaleW;
			}
		}
		
		private function doScale(scale):void {
			loader.scaleX = scale;
			loader.scaleY = scale;
		}
		
		private function onApplicationInvoke(event:InvokeEvent):void{
			var filepath:String;
			if (event.arguments.length > 0) {
				var url:String = event.arguments[0];
				var params:String = url.substring(url.indexOf("?") + 1);
				var paramKV:URLVariables = new URLVariables(params);
				filepath = paramKV.file;
			}
			else {
				return;
			}
			// support autoOrients			
			stage.align = StageAlign.LEFT;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			loader = new Loader()
			addChild(loader);
			
			var swfFilePath:File = File.applicationStorageDirectory.resolvePath(filepath); 
			var inFileStream:FileStream = new FileStream(); 
			inFileStream.open(swfFilePath, FileMode.READ); 
			var swfBytes:ByteArray = new ByteArray();
			inFileStream.readBytes(swfBytes);
			inFileStream.close();
			
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSwfLoadComplete);
			loader.loadBytes(swfBytes, loaderContext);
		}
	}
}