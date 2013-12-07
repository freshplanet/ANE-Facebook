package
{
	import com.freshplanet.ane.AirFacebook.Facebook;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	public class AirFacebookSample extends Sprite
	{
		
		private var btns:Vector.<AFSButton>;
		
		public function AirFacebookSample()
		{
			super();
			
			// init the ANE
			Facebook.getInstance().init( FacebookConfig.appID );
			Facebook.getInstance().logEnabled = true;
			
			createUI(
				{label: "Connect", 					handler: onBtnConnect},
				
				// You don't need to be connected to use those functionalities
				// it will call the native app or mFacebook in a webview
				// your user will have to be connected (or otherwise to login) in the app or in a browser
				{label: "Share a status", 			handler: onBtnShareStatus},
				{label: "Share a link", 			handler: onBtnShareLink},
				{label: "Share an OpenGraph object",handler: onBtnShareOG},
				{label: "Web Share Dialog", 		handler: onBtnWebShare}
			);
			
		}
		
		// ------------------
		// opening session
		private function onBtnConnect(e:Event):void
		{
			Facebook.getInstance().openSessionWithReadPermissions([], onSessionOpened);
		}
		
		private function onSessionOpened(success:Boolean, userCancelled:Boolean, error:String):void
		{
			
			if (!success && error)
				trace(error);
			
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
				Facebook.getInstance().shareOpenGraphDialog( "og.like", ogObject, "object", null, errorHandler );
			
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
			stage.color = 0xBBBBBB;
			const w:Number = stage.fullScreenWidth;
			
			btns = new Vector.<AFSButton>();
			
			for each( var def:Object in btnsDef )
			{
				var btn:AFSButton = new AFSButton( def.label );
				btn.addEventListener( MouseEvent.CLICK, def.handler );
				addChild( btn ) ;
				btns.push( btn ) ;
			}
			
			layout();
			stage.addEventListener(Event.RESIZE, layout);
			
		}
		
		private function layout(e:Event=null):void
		{
			const dpi:Number = Capabilities.screenDPI;
			const contentScale:Number = dpi/163;
			const cs:Number = contentScale;
			const w:Number = stage.fullScreenWidth/contentScale;
			
			var prevY:Number = 10*cs;
			
			for each ( var btn:AFSButton in btns )
			{
				btn.size = new Rectangle(0,0,(w-40)*cs, 40*cs);
				btn.x = (w/2)*cs;
				btn.y = prevY + btn.height/2;
				prevY = btn.y + btn.height/2 + 10*cs;
			}
			
		}
		
	}
	
}

import flash.display.BitmapData;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class AFSButton extends SimpleButton
{
	
	private const margins:Number=10;
	
	private var text:String;
	
	public function AFSButton(text:String)
	{
		
		this.text = text.toUpperCase();
		size = null;
		
	}
	
	public function set size( _size:Rectangle ):void
	{
		
		var tf:TextField = new TextField();
		tf.defaultTextFormat = new TextFormat( "Arial", 16, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
		tf.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
		tf.text = text;
		
		if(_size == null)
			_size = new Rectangle(0,0, tf.textWidth + margins*2, tf.textHeight + margins*2);
		
		while( tf.textWidth + margins*2 > _size.width )
			tf.text = text.substr(0, int(Math.min(tf.text.length -1, text.length -4))) + "...";
		tf.width = tf.textWidth+10;
		tf.height = tf.textHeight+2;
		var mText:Matrix = new Matrix();
		mText.translate(-tf.width/2,-tf.height/2);
		
		var up:Sprite = new Sprite();
		up.graphics.beginFill( 0x6666AA ) ;
		up.graphics.drawRect( -_size.width/2, -_size.height/2, _size.width, _size.height );
		up.graphics.endFill();
		var upText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
		upText.draw(tf);
		up.graphics.beginBitmapFill(upText, mText, false, false);
		up.graphics.drawRect(0-tf.width/2,-tf.height/2,tf.width,tf.height);
		
		var down:Sprite = new Sprite();
		down.graphics.beginFill( 0x369FE5 ) ;
		down.graphics.drawRect( -_size.width/2, -_size.height/2, _size.width, _size.height );
		down.graphics.endFill();
		var downText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
		downText.draw(tf);
		down.graphics.beginBitmapFill(downText, mText, false, false);
		down.graphics.drawRect(-tf.width/2,-tf.height/2,tf.width,tf.height);
		
		this.upState = up;
		this.overState = up;
		this.downState = down;
		this.hitTestState = up;
		
	}
	
}