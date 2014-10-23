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
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	public class SwfPlayer extends Sprite
	{
		private static var LOCAL_PATH:String = "/sdcard/Android/data/com.greelane.swfplayer";
		
		private var loader:Loader;
		private var callbackUri:String;
		private var loadingText:TextField;
		private var loaderContext:LoaderContext;
		
		public function SwfPlayer()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onApplicationInvoke, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
		}
		
		private function onSwfLoadComplete(evt:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSwfLoadComplete);
			var scale:Number = calculateScale();
			doScale(scale);
		}
		
		private function calculateScale():Number
		{
			var screenWidth:Number = stage.fullScreenWidth;
			var screenHeigh:Number = stage.fullScreenHeight;
			var loaderWidth:Number = loader.content.width;
			var loaderHeigh:Number = loader.content.height;
			
			var scaleW:Number = 1;
			var scaleH:Number = 1;
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
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onSwfLoadProgress);
			
			loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;			
			
			var filepath:String;
			if (event.arguments.length > 0) {
				var url:String = event.arguments[0];
				var params:String = url.substring(url.indexOf("?") + 1);
				var paramKV:URLVariables = new URLVariables(params);
				
				filepath = paramKV.location;
				callbackUri = paramKV.callbackUri;
				
				if (filepath.indexOf("file://") >= 0) {
					loadSwf(filepath.replace("file://", ""));
				}
				else {
					downloadFile(filepath);
				}
			}
			else {
				 filepath = "sample1.swf";
				 loader.load(new URLRequest(filepath), loaderContext);
			}
		}
		
		private function loadSwf(filePath:String):void {
			var swfFilePath:File = File.applicationStorageDirectory.resolvePath(filePath); 
			var inFileStream:FileStream = new FileStream(); 
			inFileStream.open(swfFilePath, FileMode.READ); 
			var swfBytes:ByteArray = new ByteArray();
			inFileStream.readBytes(swfBytes);
			inFileStream.close();
			loader.loadBytes(swfBytes, loaderContext);
		}
		
		private function downloadFile(url:String):void{
			var urlString:String = url;
			var urlReq:URLRequest = new URLRequest(urlString);
			var urlStream:URLStream = new URLStream();
			var fileData:ByteArray = new ByteArray();
			urlStream.addEventListener(Event.COMPLETE, loaded);
			urlStream.addEventListener(ProgressEvent.PROGRESS, onSwfDownloadProgress);
			urlStream.load(urlReq);
			
			function loaded(event:Event):void
			{
				urlStream.readBytes(fileData, 0, urlStream.bytesAvailable);
				writeAirFile();
			}
			
			function writeAirFile():void
			{ 
				// Change the folder path to whatever you want plus name your mp3
				// If the folder or folders does not exist it will create it.
				var filename:String = url.substr(url.lastIndexOf("/") + 1);
				var file:File = File.documentsDirectory.resolvePath(LOCAL_PATH);
				try {
					file.createDirectory();
				}
				catch (e:Error) {  
					
				}  
				file = File.documentsDirectory.resolvePath(LOCAL_PATH + "/" + filename);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(fileData, 0, fileData.length);
				fileStream.close();
				loadSwf(LOCAL_PATH + "/" + filename);
			}
		}
		
		private function onSwfDownloadProgress(e:ProgressEvent):void{
			if (loadingText == null) {
				loadingText = new TextField();
				loadingText.scaleX = 2;
				loadingText.scaleY = 2;
				loadingText.width = 100;
				addChild(loadingText);
			}
			if (e.bytesLoaded == e.bytesTotal) {
				removeChild(loadingText);
				loadingText = null;
				return;
			}
			
			loadingText.text = "Downloading...";
		}
		
		private function onSwfLoadProgress(e:ProgressEvent):void{
			if (loadingText == null) {
				loadingText = new TextField();
				loadingText.scaleX = 2;
				loadingText.scaleY = 2;
				loadingText.width = 100;
				addChild(loadingText);
			}
			if (e.bytesLoaded == e.bytesTotal) {
				removeChild(loadingText);
				loadingText = null;
				return;
			}
			
			loadingText.text = "Loading..." + (e.bytesLoaded / e.bytesTotal)*100 + "%";
		}
		
		private function onBtnCloseClick(evt:Event):void{
			if (callbackUri) {
				navigateToURL(new URLRequest(callbackUri));
			}
			NativeApplication.nativeApplication.exit();
		}
		
		private function onKeyUpHandler(evt:KeyboardEvent):void {
			if (evt.keyCode == Keyboard.BACK && callbackUri != null) {
				navigateToURL(new URLRequest(callbackUri));
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