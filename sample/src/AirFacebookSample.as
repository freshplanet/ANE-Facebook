package
{
	import com.freshplanet.ane.AirFacebook.Facebook;
	
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class AirFacebookSample extends Sprite
	{
		
		private var btnConnect:SimpleButton;
		private var btnShareStatus:SimpleButton;
		private var btnShareLink:SimpleButton;
		
		public function AirFacebookSample()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			const w:Number = stage.fullScreenWidth;
			
			btnConnect = createSkinnedButton( "Connect", new Rectangle(0,0,w - 40, 40) );
			btnConnect.addEventListener( MouseEvent.CLICK, onBtnConnect );
			btnConnect.x = w/2;
			btnConnect.y = btnConnect.height/2 + 10;
			addChild( btnConnect ) ;
			
			btnShareStatus = createSkinnedButton("Share a status", new Rectangle(0,0,w - 40, 40));
			btnShareStatus.addEventListener( MouseEvent.CLICK, onBtnShareStatus );
			btnShareStatus.x = w/2;
			btnShareStatus.y = btnConnect.y + btnConnect.height/2 + 10 + btnShareStatus.height/2;
			addChild( btnShareStatus );
			
			btnShareLink = createSkinnedButton("Share a link", new Rectangle(0,0,w - 40, 40));
			btnShareLink.addEventListener( MouseEvent.CLICK, onBtnShareLink );
			btnShareLink.x = w/2;
			btnShareLink.y = btnShareStatus.y + btnShareStatus.height/2 + 10 + btnShareLink.height/2;
			addChild( btnShareLink );
			
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
		
		
		private function errorHandler(data:String):void{
			
			trace(data);
			
		}
		
		// ------------------
		// UI util
		private static function createSkinnedButton(text:String, size:Rectangle = null):SimpleButton{
			
			text = text.toUpperCase();
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat( "Arial", 16, 0xFFFFFF, false, false, false, null, null, TextFormatAlign.CENTER );
			tf.filters = [new DropShadowFilter(2,45,0,.3,1,1,1,1)];
			tf.text = text;
			
			const margins:Number=10;
			
			if(size == null)
				size = new Rectangle(0,0, tf.textWidth + margins*2, tf.textHeight + margins*2);
			
			while( tf.textWidth + margins*2 > size.width )
				tf.text = text.substr(0, int(Math.min(tf.text.length -1, text.length -4))) + "...";
			tf.width = tf.textWidth+10;
			tf.height = tf.textHeight+2;
			var mText:Matrix = new Matrix();
			mText.translate(-tf.width/2,-tf.height/2);
			
			var up:Sprite = new Sprite();
			up.graphics.beginFill( 0x6666AA ) ;
			up.graphics.drawRect( -size.width/2, -size.height/2, size.width, size.height );
			up.graphics.endFill();
			var upText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
			upText.draw(tf);
			up.graphics.beginBitmapFill(upText, mText, false, false);
			up.graphics.drawRect(0-tf.width/2,-tf.height/2,tf.width,tf.height);
			
			var down:Sprite = new Sprite();
			down.graphics.beginFill( 0x9999FF ) ;
			down.graphics.drawRect( -size.width/2, -size.height/2, size.width, size.height );
			down.graphics.endFill();
			var downText:BitmapData = new BitmapData( Math.ceil(tf.width), Math.ceil(tf.height), true, 0 );
			downText.draw(tf);
			down.graphics.beginBitmapFill(downText, mText, false, false);
			down.graphics.drawRect(-tf.width/2,-tf.height/2,tf.width,tf.height);
			
			return new SimpleButton(up,up,down,down);// left right left right B A Start
			
		}
		
	}
}