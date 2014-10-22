package
{
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	public class SwfPlayer extends Sprite
	{
		private var loader:Loader;
		private var returnUri:String;
		
		public function SwfPlayer()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onApplicationInvoke, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
			
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
			removeAllChilds();
			// support autoOrients			
			stage.align = StageAlign.LEFT;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			loader = new Loader()
			addChild(loader);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSwfLoadComplete);
			
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;			
			
			var filepath:String;
			if (event.arguments.length > 0) {
				var url:String = event.arguments[0];
				var params:String = url.substring(url.indexOf("?") + 1);
				var paramKV:URLVariables = new URLVariables(params);
				filepath = paramKV.file;
				returnUri = paramKV.returnUri;
				var swfFilePath:File = File.applicationStorageDirectory.resolvePath(filepath); 
				var inFileStream:FileStream = new FileStream(); 
				inFileStream.open(swfFilePath, FileMode.READ); 
				var swfBytes:ByteArray = new ByteArray();
				inFileStream.readBytes(swfBytes);
				inFileStream.close();

				loader.loadBytes(swfBytes, loaderContext);
			}
			else {
				 filepath = "sample1.swf";
				 loader.load(new URLRequest(filepath), loaderContext);
			}
		}
		
		private function onBtnCloseClick(evt:Event):void{
			if (returnUri) {
				navigateToURL(new URLRequest(returnUri));
			}
			NativeApplication.nativeApplication.exit();
		}
		
		private function onKeyUpHandler(evt:KeyboardEvent):void {
			if (evt.keyCode == Keyboard.BACK && returnUri != null) {
				navigateToURL(new URLRequest(returnUri));
			}
			NativeApplication.nativeApplication.exit();
		}
		
		private function removeAllChilds():void
		{
			while (numChildren > 0) {
				removeChildAt(0);
			}
		}
	}
}