package
{
	import com.freshplanet.ane.AirFacebook.Facebook;
	import com.freshplanet.ane.AirFacebook.FacebookPermissionEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class AirFacebookSample extends Sprite
	{
		
		// set this to true to be able to click on disbled buttons and test bad usecases (e.g. requesting while not connected) 
		public static var ALLOW_DISABLED_BUTTON_CLICK:Boolean = false;
		
		private var btnsList:Vector.<AFSButton>;
		private var btns:Object;
		
		private var statusBar:Sprite;
		private var statusConnected:TextField;
		private var statusPermissions:TextField;
		
		public function AirFacebookSample()
		{
			super();
			
			// init the ANE
			Facebook.getInstance().init( FacebookConfig.appID );
			Facebook.getInstance().logEnabled = true;
			
			createUI(
				{id:"connect",			label: "Connect",										handler: onBtnConnect,		scheme:AFSButton.BLUE},
				
				// those need connection
				{id:"graph_og_like",	label: "like freshplanet.com",		deco:"[OG]",		handler: onBtnGraphOG,		scheme:AFSButton.BLUE, cond:isSessionOpened },
				
				// You don't need to be connected to use those functionalities
				// it will call the native app or mFacebook in a webview
				// your user will have to be connected (or otherwise to login) in the app or in a browser
				{id:"dialog_status",	label: "Share a status",			deco:"[Dialog]",	handler: onBtnShareStatus,	scheme:AFSButton.BLUE},
				{id:"dialog_link",		label: "Share a link", 				deco:"[Dialog]",	handler: onBtnShareLink,	scheme:AFSButton.BLUE},
				{id:"dialog_og",		label: "Share an OpenGraph object",	deco:"[Dialog]",	handler: onBtnShareOG,		scheme:AFSButton.BLUE},
				{id:"web_dialog",		label: "Web Share Dialog", 			deco:"[Dialog]",	handler: onBtnWebShare,		scheme:AFSButton.BLUE}
			);
			
			if(isSessionOpened())
				onSessionOpened(true,null,null);
			
		}
		
		// ------------------
		private function isSessionOpened():Boolean{
			return Facebook.getInstance().isSessionOpen;
		}
		
		// ------------------
		// opening session
		private function onBtnConnect(e:Event):void
		{
			Facebook.getInstance().openSessionWithReadPermissions([], onSessionOpened);
		}
		
		private function onBtnDisconnect(e:Event):void
		{
			Facebook.getInstance().closeSessionAndClearTokenInformation();
			btnsList[0].text = "Connect";
			btnsList[0].handler = onBtnConnect;
			
			refresh(); //deactivate btns
		}
		
		private function onSessionOpened(success:Boolean, userCancelled:Boolean, error:String):void
		{
			
			if (!success && error)
			{
				trace("Session opening error:", error);
				return;
			}
			
			if(success)
			{
				btnsList[0].text = "Disconnect";
				btnsList[0].handler = onBtnDisconnect;
				
				refresh(); //activate btns
			}
			
		}
		
		private static const ALLOWED_PERMISSIONS:Array = ["publish_actions"];
		private function onRequirePermission(permissions:Array, callback:Function):void
		{
			for ( var i:int = 0; i<permissions.length; ++i)
			{
				// you should take great care of the permissions you are requesting
				if(ALLOWED_PERMISSIONS.indexOf(permissions[i]) < 0)
					permissions.splice(i,1);
			}
			
			if(permissions.length > 0)
			{
				Facebook.getInstance().reauthorizeSessionWithPublishPermissions(permissions, callback)
			}
		}
		
		// ----------------
		// 
		private function onBtnGraphOG(e:Event):void
		{
			var ogObject:Object = {
				object:"http://freshplanet.com"
			};
			
			var path:String = "me/og.likes";
			
			function callGraphPath():void{
				Facebook.getInstance().requestWithGraphPath(path, ogObject, "POST",
					function(data:Object):void
					{
						trace(JSON.stringify(data));
					});
			}
			
			// handle permission missing
			function onPermissionMissing(e:FacebookPermissionEvent):void
			{
				Facebook.getInstance().removeEventListener(FacebookPermissionEvent.PERMISSION_NEEDED, onPermissionMissing);
				onRequirePermission(e.permissions, function(success:Boolean, userCancelled:Boolean, error:String):void{
					if(success)
						callGraphPath();
				});
			}
			Facebook.getInstance().addEventListener(FacebookPermissionEvent.PERMISSION_NEEDED, onPermissionMissing);
			
			callGraphPath();
			
		}
		
		// ------------------
		// showing dialogs
		private function onBtnShareStatus(e:Event):void
		{
			if(Facebook.getInstance().canPresentShareDialog())
				Facebook.getInstance().shareStatusDialog( errorHandler );
			else
				Facebook.getInstance().webDialog("feed", null, errorHandler);
		}
		
		private function onBtnShareLink(e:Event):void
		{
			if(Facebook.getInstance().canPresentShareDialog())
				Facebook.getInstance().shareLinkDialog( "http://freshplanet.com/", null, null, null, null, errorHandler );
			else
				Facebook.getInstance().webDialog( "feed", { 'link':"http://freshplanet.com" }, errorHandler );
		}
		
		private function onBtnShareOG(e:Event):void
		{
			
			var ogObject:Object = {
				object:"http://freshplanet.com"
			};
			var canPresentDialog:Boolean = Facebook.getInstance().canPresentOpenGraphDialog( "og.like", ogObject );
			
			if(canPresentDialog)
				Facebook.getInstance().shareOpenGraphDialog( "og.likes", ogObject, "object", null, errorHandler );
			
		}
		
		private function onBtnWebShare(e:Event):void
		{
			Facebook.getInstance().webDialog( "feed", { 'link':"http://freshplanet.com" }, errorHandler );
		}
		
		
		private function errorHandler(data:Object):void{
			
			trace(JSON.stringify(data));
			
		}
		
		
		// ------------------
		// UI stuff, nothing to see here
		
		private function createUI( ...btnsDef ):void
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.color = 0xAAAAAA;
			const w:Number = stage.fullScreenWidth;
			
			statusBar = new Sprite();
			statusBar.x = statusBar.y = 0;
			statusConnected = new TextField();
			statusConnected.defaultTextFormat = new TextFormat( "Arial", 14, 0x999999, false, false, false, null, null, TextFormatAlign.LEFT );
			statusConnected.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
			statusPermissions = new TextField();
			statusConnected.defaultTextFormat = new TextFormat( "Arial", 14, 0x999999, false, false, false, null, null, TextFormatAlign.RIGHT );
			statusConnected.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
			statusBar.addChild(statusConnected);
			statusBar.addChild(statusPermissions);
			addChild(statusBar);
			
			btnsList = new Vector.<AFSButton>();
			
			for each( var def:Object in btnsDef )
			{
				var btn:AFSButton = new AFSButton( def.label, def.cond );
				btn.decoration = def.deco;
				btn.handler = def.handler;
				addChild( btn );
				btnsList.push( btn );
			}
			
			refresh();
			stage.addEventListener(Event.RESIZE, draw);
			
		}
		
		private function refresh(e:Event=null):void
		{
			statusConnected.text = isSessionOpened() ? "Connected" : "Not Connected";
			
			draw();
		}
		
		private function draw(e:Event=null):void
		{
			
			const dpi:Number = Capabilities.screenDPI;
			const contentScale:Number = dpi/163;
			const cs:Number = contentScale;
			const w:Number = stage.fullScreenWidth/contentScale;
			
			statusBar.graphics.clear();
			statusBar.graphics.beginFill(0xFFFFFF);
			statusBar.graphics.drawRect(0, 0, w*cs, 50*cs);
			statusConnected.x = statusConnected.y = 10*cs;
			statusConnected.width = 1.1*statusConnected.textWidth;
			statusConnected.height = 1.2*statusConnected.textHeight;
			statusPermissions.y = 10*cs;
			statusPermissions.width = 1.1*statusPermissions.textWidth;
			statusPermissions.height = 1.2*statusPermissions.textHeight;
			statusPermissions.x = statusBar.width - (statusPermissions.width + 10*cs);
			
			var prevY:Number = statusBar.y + statusBar.height + 10*cs;
			
			for each ( var btn:AFSButton in btnsList )
			{
				btn.size = new Rectangle(0,0,(w-40)*cs, 40*cs);
				btn.x = (w/2)*cs;
				btn.y = prevY + btn.height/2;
				prevY = btn.y + btn.height/2 + 10;
			}
			
		}
		
	}
	
}

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class AFSButton extends SimpleButton
{
	
	public static const BLUE:int = 1;
	private static const BLUE_BG:int = 0x6666AA;
	private static const BLUE_TXT:int = 0xFFFFFF;
	
	public static const WHITE:int = 2;
	private static const WHITE_BG:int = 0xFFFFFF;
	private static const WHITE_TXT:int = 0x6666AA;
	
	private const margins:Number=10;
	
	private var _decoration:Object;
	
	private var _text:String;
	
	private var _size:Rectangle;
	
	private var _handler:Function;
	
	private var _condition:Function;
	
	public function AFSButton(text:String, cond:Function)
	{
		
		this._condition = cond;
		this.text = text;
		size = null;
		
	}
	
	public function set decoration(d:Object):void
	{
		this._decoration = d;
		draw();
	}
	
	public function set text(t:String):void
	{
		_text = t.toUpperCase();
		draw();
	}
	
	public function set handler( f:Function ):void
	{
		if(_handler)
			removeEventListener(MouseEvent.CLICK, _handler);
		_handler = f;
		addEventListener( MouseEvent.CLICK, _handler );
	}
	
	public function set size( s:Rectangle ):void
	{
		_size = s;
		draw();
	}
	
	private function draw():void
	{
		
		enabled = _condition == null || _condition();
		
		var _text:String = this._text;
		
		var deco:BitmapData = null;
		if(_decoration != null)
		{
			if(_decoration is String)
			{
//				var decoTf:TextField = new TextField();
//				decoTf.defaultTextFormat = new TextFormat( "Arial", 16, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.LEFT );
//				decoTf.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
//				decoTf.text = _decoration as String;
//				decoTf.width = decoTf.textWidth+10;
//				decoTf.height = decoTf.textHeight+2;
//				deco = new BitmapData(int(decoTf.width), int(decoTf.height), true, 0xFFFFFFFF);
//				deco.draw(decoTf);
				_text = _decoration + ' ' + _text;
			}
			else if(_decoration is DisplayObject)
			{
				deco = new BitmapData(Math.ceil(_decoration.width), Math.ceil(_decoration.height), true, 0);
				deco.draw(_decoration as DisplayObject);
			}
		}
		
		var tf:TextField = new TextField();
		tf.defaultTextFormat = new TextFormat( "Arial", 16, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
		tf.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
		tf.text = _text;
		
		var decoWidth:int = deco!=null ? deco.width + margins : 0; 
		
		if(_size == null)
			_size = new Rectangle(0,0, decoWidth + tf.textWidth + margins*2, tf.textHeight + margins*2);
		
		while( decoWidth + tf.textWidth + margins*2 > _size.width && tf.text.length > 4 )
			tf.text = _text.substr(0, int(Math.min(tf.text.length -1, 1))) + "...";
		tf.width = tf.textWidth+10;
		tf.height = tf.textHeight+2;
		var mText:Matrix = new Matrix();
		mText.translate(-tf.width/2,-tf.height/2);
		
		var up:Sprite = new Sprite();
		up.graphics.beginFill( 0x6666AA ) ;
		up.graphics.drawRect( -_size.width/2, -_size.height/2, _size.width, _size.height );
		up.graphics.endFill();
		if(deco!=null){
			up.graphics.beginBitmapFill(deco);
			up.graphics.drawRect(0-_size.width/2+margins,-_size.height/2+margins,deco.width,deco.height);
		}
		var upText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
		upText.draw(tf);
		up.graphics.beginBitmapFill(upText, mText, false, false);
		up.graphics.drawRect(0-tf.width/2,-tf.height/2,tf.width,tf.height);
		
		var down:Sprite = new Sprite();
		down.graphics.beginFill( 0x369FE5 ) ;
		down.graphics.drawRect( -_size.width/2, -_size.height/2, _size.width, _size.height );
		down.graphics.endFill();
		if(deco!=null){
			down.graphics.beginBitmapFill(deco);
			down.graphics.drawRect(0-_size.width/2+margins,-_size.height/2+margins,deco.width,deco.height);
		}
		var downText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
		downText.draw(tf);
		down.graphics.beginBitmapFill(downText, mText, false, false);
		down.graphics.drawRect(-tf.width/2,-tf.height/2,tf.width,tf.height);
		
		this.upState = up;
		this.overState = up;
		this.downState = down;
		this.hitTestState = up;
		
		if(!enabled) this.alpha = .7;
		else this.alpha = 1;
		
		this.mouseEnabled = enabled || AirFacebookSample.ALLOW_DISABLED_BUTTON_CLICK;
		
	}
	
}