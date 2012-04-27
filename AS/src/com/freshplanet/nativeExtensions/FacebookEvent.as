//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.nativeExtensions
{
	import flash.events.Event;
	
	public class FacebookEvent extends Event
	{
		
		public static const USER_LOGGED_IN_SUCCESS_EVENT:String = 'userLoggedInSuccessEvent';
		public static const USER_LOGGED_OUT_SUCCESS_EVENT:String = 'userLoggedOutSuccessEvent'
		public static const USER_LOGGED_IN_FACEBOOK_ERROR_EVENT:String = 'userLoggedInFacebookErrorEvent';
		public static const USER_LOGGED_IN_ERROR_EVENT:String = 'userLoggedInErrorEvent';
		public static const USER_LOGGED_IN_CANCEL_EVENT:String = 'userLoggedInCancelEvent';
		public static const GRAPH_API_SUCCESS_EVENT:String = 'graphApiSuccessEvent';
		
		
		public var token:String;
		public var expirationTime:String;
		public var message:String;
		public var data:Object;
		
		public function FacebookEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}