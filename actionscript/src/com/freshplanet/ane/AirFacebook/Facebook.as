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
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class Facebook extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		/** Facebook is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1;
		}
		
		public function Facebook()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
				
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
		
		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 * If <code>false</code>, logs will be displayed only at the native level.
		 */
		public function get logEnabled() : Boolean
		{
			return _logEnabled;
		}
		
		public function set logEnabled( value : Boolean ) : void
		{
			_logEnabled = value;
		}
		
		/**
		 * Initialize the Facebook extension.
		 * 
		 * @param appID A Facebook application ID.
		 * @param urlSchemeSuffix (Optional) The URL Scheme Suffix to be used in scenarios where multiple iOS apps
		 * use one Facebook App ID. Must contain only lowercase letters.
		 */
		public function init( appID : String, urlSchemeSuffix : String = null ) : void
		{
			if (!isSupported) return;
			
			_context.call('init', appID, urlSchemeSuffix);
		}
		
		/** True if a Facebook session is open, false otherwise. */
		public function get isSessionOpen() : Boolean
		{
			if (!isSupported) return false;
			
			return _context.call('isSessionOpen');
		}
		
		/** The current Facebook access token, or null if no session is open. */
		public function get accessToken() : String
		{
			if (!isSupported) return null;
			
			return _context.call('getAccessToken') as String;
		}
		
		/**
		 * The expiration timestamp (in seconds since Unix epoch) associated with the current Facebook access token,
		 * or 0 if the session doesn't expire or doesn't exist.
		 */
		public function get expirationTimestamp() : Number
		{
			if (!isSupported) return 0;
			
			return _context.call('getExpirationTimestamp') as Number;
		}
		
		/**
		 * Open a new session with a given set of read permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * @param systemFlow Boolean indicating if the native system flow should be used instead of
		 * fast-app switching on iOS 6 and above. Default: <code>true</code>.
		 * 
		 * @see #openSessionWithPublishPermissions()
		 * @see #reauthorizeSessionWithReadPermissions()
		 * @see #reauthorizeSessionWithPublishPermissions()
		 */
		public function openSessionWithReadPermissions( permissions : Array, callback : Function = null, systemFlow:Boolean = true ) : void
		{
			openSessionWithPermissionsOfType(permissions, "read", callback, systemFlow);
		}
		
		/**
		 * Open a new session with a given set of publish permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>publish</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * @param systemFlow Boolean indicating if the native system flow should be used instead of
		 * fast-app switching on iOS 6 and above. Default: <code>true</code>.
		 * 
		 * @see #openSessionWithReadPermissions()
		 * @see #reauthorizeSessionWithReadPermissions()
		 * @see #reauthorizeSessionWithPublishPermissions()
		 */
		public function openSessionWithPublishPermissions( permissions : Array, callback : Function = null, systemFlow:Boolean = true ) : void
		{
			openSessionWithPermissionsOfType(permissions, "publish", callback, systemFlow);
		}
		
		/**
		 * Reauthorize the current session with a given set of read permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #reauthorizeSessionWithPublishPermissions()
		 */
		public function reauthorizeSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			reauthorizeSessionWithPermissionsOfType(permissions, "read", callback);
		}
		
		/**
		 * Reauthorize the current session with a given set of publish permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>publish</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #reauthorizeSessionWithReadPermissions()
		 */
		public function reauthorizeSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void
		{
			reauthorizeSessionWithPermissionsOfType(permissions, "publish", callback);
		}
		
		/** Close the current Facebook session and delete the token from the cache. */
		public function closeSessionAndClearTokenInformation() : void
		{
			if (!isSupported) return;
			
			_context.call('closeSessionAndClearTokenInformation');
		}
		
		/**
		 * Run a Facebook request with a Graph API path.
		 * 
		 * @param graphPath A Graph API path.
		 * @param parameters (Optional) An object (key-value pairs) containing the request parameters.
		 * @param httpMethod (Optional) The HTTP method to use (GET, POST or DELETE). Default is GET.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 */
		public function requestWithGraphPath( graphPath : String, parameters : Object = null, httpMethod : String = "GET", callback : Function = null ) : void
		{
			if (!isSupported) return;
			
			// Verify the HTTP method
			if (httpMethod != "GET" && httpMethod != "POST" && httpMethod != "DELETE")
			{
				log("ERROR - Invalid HTTP method: " + httpMethod + " (must be GET, POST or DELETE)");
				return;
			}
			
			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in parameters)
			{
				var value:String = parameters[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}
			
			// Register the callback
			var callbackName:String = getNewCallbackName(callback);
			
			// Execute the request
			_context.call('requestWithGraphPath', graphPath, keys, values, httpMethod, callbackName);
		}
		
		/**
		 * Open a Facebook dialog.
		 * 
		 * @param method A dialog method (eg. login, feed...).
		 * @param parameters (Optional) An object (key-value pairs) containing the dialog parameters.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 * @param allowNativeUI (Optional) If true, we will try to use the native sharing sheet on iOS 6.
		 * Native sharing sheet will only be used if <code>method</code> is <em>feed</em> and <code>
		 * parameters</code> doesn't contain a non-empty <em>to</em> parameter. If the native sharing
		 * sheet can be used, only the following parameters will be used: name, picture, link. Default
		 * is true.
		 */
		public function dialog( method : String, parameters : Object = null, callback : Function = null, allowNativeUI : Boolean = true ) : void
		{
			if (!isSupported) return;
			
			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in parameters)
			{
				var value:String = parameters[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}
			
			// Register the callback
			var callbackName:String = getNewCallbackName(callback);
			
			// Open the dialog
			_context.call('dialog', method, keys, values, callbackName, allowNativeUI);
		}
		
		/** Register the appId for install tracking. */
		public function publishInstall(appId:String):void
		{
			if (!isSupported) return;
			
			_context.call('publishInstall', appId);
		}
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.AirFacebook";
		
		private static var _instance : Facebook;
		
		private var _context : ExtensionContext;
		private var _logEnabled : Boolean = false;
		private var _openSessionCallback : Function;
		private var _reauthorizeSessionCallback : Function;
		private var _requestCallbacks : Object = {};
		
		private function openSessionWithPermissionsOfType( permissions : Array, type : String, callback : Function = null, systemFlow : Boolean = true ) : void
		{
			if (!isSupported) return;
			
			_openSessionCallback = callback;
			_context.call('openSessionWithPermissions', permissions, type, systemFlow);
		}
		
		private function reauthorizeSessionWithPermissionsOfType( permissions : Array, type : String, callback : Function = null ) : void
		{
			if (!isSupported) return;
			
			if (!isSessionOpen)
			{
				callback(false, false, "No opened session");
				return;
			}
			
			_reauthorizeSessionCallback = callback;
			_context.call('reauthorizeSessionWithPermissions', permissions, type);
		}
		
		private function getNewCallbackName( callback : Function ) : String
		{
			// Generate callback name based on current time
			var date:Date = new Date();
			var callbackName:String = date.time.toString();
			
			// Clean up old callback if the name already exists
			if (_requestCallbacks.hasOwnProperty(callbackName))
			{
				delete _requestCallbacks[callbackName]
			}
			
			// Save new callback under this name
			_requestCallbacks[callbackName] = callback;
			
			return callbackName;
		}
		
		private function onInvoke( event : InvokeEvent ) : void
		{
			if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				if (event.arguments != null && event.arguments.length > 0)
				{
					// if the invoke event arguments consist in a Referer begining with 'fb'
					var url:String = event.arguments[0] as String;
					if ( url != null && url.indexOf("fb") == 0)
					{
						_context.call("handleOpenURL", url);
					}
				}
			}
		}
		
		private function onStatus( event : StatusEvent ) : void
		{
			var today:Date = new Date();
			var callback:Function;
			
			if (event.code.indexOf("SESSION") != -1) // If the event code contains SESSION, it's an open/reauthorize session result
			{
				var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
				var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
				var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;
				
				if (event.code.indexOf("OPEN") != -1) callback = _openSessionCallback;
				else if (event.code.indexOf("REAUTHORIZE") != -1) callback = _reauthorizeSessionCallback;
				
				_openSessionCallback = null;
				_reauthorizeSessionCallback = null;
				
				if (callback != null) callback(success, userCancelled, error);
			}
			else if (event.code == "LOGGING") // Simple log message
			{
				log(event.level);
			}
			else // Default case: we check for a registered callback associated with the event code
			{
				if (_requestCallbacks.hasOwnProperty(event.code))
				{
					callback = _requestCallbacks[event.code];
					var data:Object;
					
					if (callback != null)
					{
						try
						{
							data = JSON.parse(event.level);
							if (accessToken != null)
							{
								data["accessToken"] = accessToken;
							}
						}
						catch (e:Error)
						{
							log("ERROR - " + e);
						}
						
						callback(data);
						
						delete _requestCallbacks[event.code];
					}
				}
			}
		}
		
		private function log( message : String ) : void
		{
			if (_logEnabled) trace("[Facebook] " + message);
		}
	}
}
