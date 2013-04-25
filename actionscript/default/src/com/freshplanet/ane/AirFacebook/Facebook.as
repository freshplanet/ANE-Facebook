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

package com.freshplanet.ane.AirFacebook
{
	import flash.events.EventDispatcher;
	
	public class Facebook extends EventDispatcher implements IAirFacebook
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		/** Facebook is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return false;
		}
		
		public function Facebook()
		{
			if (!_instance)
			{
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance() : Facebook
		{
			return _instance ? _instance : new Facebook();
		}
		
		/** @inheritDoc */
		public function get logEnabled() : Boolean
		{
			return _logEnabled;
		}
		
		public function set logEnabled( value : Boolean ) : void
		{
			_logEnabled = value;
		}
		
		/** @inheritDoc */
		public function init( appID : String, urlSchemeSuffix : String = null ) : void
		{
			return;
		}
		
		/** @inheritDoc */
		public function get isSessionOpen() : Boolean
		{
			return false;
		}
		
		/** @inheritDoc */
		public function get accessToken() : String
		{
			return null;
		}
		
		/** @inheritDoc */
		public function get expirationTimestamp() : Number
		{
			return 0;
		}
		
		/** @inheritDoc */
		public function openSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			callback(false, false, "Facebook is not supported on this platform");
		}
		
		/** @inheritDoc */
		public function openSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void
		{
			callback(false, false, "Facebook is not supported on this platform");
		}
		
		/** @inheritDoc */
		public function openSessionWithPermissions( permissions : Array, callback : Function = null ) : void
		{
			callback(false, false, "Facebook is not supported on this platform");
		}
		
		/** @inheritDoc */
		public function reauthorizeSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			callback(false, false, "Facebook is not supported on this platform");
		}
		
		/** @inheritDoc */
		public function reauthorizeSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void
		{
			callback(false, false, "Facebook is not supported on this platform");
		}
		
		/** @inheritDoc */
		public function closeSessionAndClearTokenInformation() : void
		{
			return;
		}
		
		/** @inheritDoc */
		public function requestWithGraphPath( graphPath : String, parameters : Object = null, httpMethod : String = "GET", callback : Function = null ) : void
		{
			callback(null);
		}
		
		/** @inheritDoc */
		public function dialog( method : String, parameters : Object = null, callback : Function = null, allowNativeUI : Boolean = true ) : void
		{
			callback(null);
		}
		
		/** @inheritDoc */
		public function publishInstall( appId:String ):void
		{
			return;
		}
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static var _instance : Facebook;
		private var _logEnabled : Boolean = false;
	}
}
