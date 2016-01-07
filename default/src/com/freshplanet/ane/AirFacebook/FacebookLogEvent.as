package com.freshplanet.ane.AirFacebook
{
	import flash.events.Event;

	public class FacebookLogEvent extends Event
	{
		public static const LOG:String = "LOG";
		private var message:String;

		public function FacebookLogEvent( type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.message = message;
		}

		public function getMessage():String {
			return message;
		}
	}
}

