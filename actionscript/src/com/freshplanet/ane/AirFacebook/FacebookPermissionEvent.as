package com.freshplanet.ane.AirFacebook
{

	import flash.events.Event;

	public class FacebookPermissionEvent extends Event
	{

		public static const PERMISSION_NEEDED:String = "com.freshplanet.ane.AirFacebook.FacebookPermissionEvent.PERMISSION_NEEDED";

		public var permissions:Array;

		public function FacebookPermissionEvent(type:String, permissions:Array)
		{

			super(type);
			this.permissions = permissions;
			
		}
		
	}
}