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
	import com.freshplanet.ane.AirFacebook.FacebookPermissionEvent;

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
		 * This is only important on Android - if you are using stage3D for display at the time you log in to FB,
		 * set this to true to avoid the display freezing
		 */
		public function setUsingStage3D(using3d:Boolean) : void 
		{
			if(Capabilities.manufacturer.indexOf("Android") > -1) {
				_context.call('setUsingStage3D', using3d);
			}
		}
		
		/**
		 * Initialize the Facebook extension.
		 * 
		 * @param appID             A Facebook application ID.
         * @param legacyMode        TRUE enables Graph 1.0, FALSE uses current Graph API.
		 * @param urlSchemeSuffix   (Optional) The URL Scheme Suffix to be used in scenarios where multiple iOS apps
		 *                          use one Facebook App ID. Must contain only lowercase letters.
		 */
		public function init(appID:String, urlSchemeSuffix : String = null ) : void
		{
			if (!isSupported) return;
			
			_context.call('init', appID, urlSchemeSuffix);
		}
		
		/**
		 * Track an activation of the app
		 */
		public function activateApp() : void
		{
			if (!isSupported) return;
			
			_context.call('activateApp');
		}
		
		/**
		 * Fetches any deferred applink data and attempts to open the returned url
		 */
		public function openDeferredAppLink() : void
		{
			if (!isSupported) return;
			
			_context.call('openDeferredAppLink');
		}
		
		/** True if a Facebook session is open, false otherwise. */
		public function get isSessionOpen() : Boolean
		{
			if (!isSupported) return false;
			
			return _context.call('isSessionOpen');
		}
		
		/** The current Facebook access token, or null if no session is open. */
		public function get accessToken():FBAccessToken
		{
			if (!isSupported) return null;

			var accessToken:FBAccessToken = _context.call('getAccessToken') as FBAccessToken;
			log(accessToken.toString());
			return accessToken;
		}

		public function get profile():FBProfile
		{
			if (!isSupported) return null;

			var profile:FBProfile = _context.call('getProfile') as FBProfile;
			log(profile.toString());
			return profile;
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
		 * Determine if we can open a native share dialog with the given parameters.
		 * Call this method to decide wether you should use <code>shareStatusDialog</code> or <code>webDialog</code>
		 */
		public function canPresentShareDialog():Boolean
		{

			return _context.call('canPresentShareDialog') ;

		}

		/**
		 * Open a native Facebook dialog for sharing a link
		 * This requires that the Facebook app is installed on the device,
		 * To make sure this succeeds, call canPresentShareDialog, otherwise
		 * you can fall back to a web view with the <code>webDialog</code> method
		 */
		public function shareStatusDialog( callback:Function ):void
		{

			_context.call('shareStatusDialog', getNewCallbackName(callback) );

		}

		/**
		 * Open a native Facebook dialog for sharing a link
		 * This requires that the Facebook app is installed on the device,
		 * To make sure this succeeds, call canPresentShareDialog, otherwise
		 * you can fall back to a web view with the <code>webDialog</code> method
		 *
		 * @param link (Optional) Link to share.
		 * @param name (Optional) Title of the publication.
		 * @param caption (Optional) Short summary of the link content.
		 * @param description (Optional) Description of the link content.
		 * @param pictureUrl (Optional) Url of the attached picture.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 */
		public function shareLinkDialog(
			link:String =null,
			name:String =null,
			caption:String =null,
			description:String =null,
			pictureUrl:String =null,
			clientState:Object =null,
			callback:Function =null ):void
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in clientState)
			{
				var value:String = clientState[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			_context.call('shareLinkDialog', link, name, caption, description, pictureUrl, keys, values, getNewCallbackName(callback)) ;

		}

		/**
		 * Determine if we can open a native share dialog for OpenGraph with the given parameters.
		 * Call this method to know if you can use <code>shareOpenGraphDialog</code>
		 */
		public function canPresentOpenGraphDialog( actionType:String, graphObject:Object, previewProperty:String =null):Boolean
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in graphObject)
			{
				var value:String = graphObject[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			return _context.call('canPresentOpenGraphDialog', actionType, keys, values, previewProperty) ;

		}

		/**
		 * Open a native Facebook dialog for sharing an OpenGraph action
		 * This requires that the Facebook app is installed on the device,
		 * To make sure this succeeds, call canPresentOpenGraphDialog
		 *
		 * @param actionType the OpenGraph action you want to share (e.g. books.read)
		 * @param graphObject the OpenGraph object you want to share, set properties accordingly with
		 * the definition you created on developers.facebook.com (e.g. { book:"http://freshplanet.com/books/how-to-make-anes.html" })
		 * @param previewProperty defines the property over wich the story should emphasis (e.g. 'book')
		 * @param clientState (Optional) deprecated
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 */
		public function shareOpenGraphDialog(
			actionType:String,
			graphObject:Object,
			previewProperty:String =null,
			clientState:Object =null,
			callback:Function =null ):void
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in graphObject)
			{
				var value:String = graphObject[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			// Separate parameters keys and valuesm for clientState
			var cskeys:Array = []; var csvalues:Array = [];
			for (var cskey:String in clientState)
			{
				value = clientState[key] as String;
				if (value)
				{
					cskeys.push(key); 
					csvalues.push(value);
				}
			}

			_context.call('shareOpenGraphDialog', actionType, keys, values, previewProperty, cskeys, csvalues, getNewCallbackName(callback));

		}

		
		/**
		 * Determine if we can open a native Message Dialog.
		 * Call this method to know if you can use <code>presentMessageDialogWithLinkWithParams</code>
		 */
		public function canPresentMessageDialog():Boolean
		{
			var result:Boolean =  _context.call('canPresentMessageDialog');
			return result;
		}
		
		
		public function presentMessageDialogWithLinkAndParams(
			linkUrl:String,
			name:String,
			caption:String,
			description:String,
			pictureUrl:String,
			callback:Function ):void
		{
			var keys:Array = ["link", "name", "caption", "description", "picture"];
			var values:Array = [linkUrl, name, caption, description, pictureUrl];
			
			// Register the callback
			var callbackName:String = getNewCallbackName(callback);
			
			_context.call('presentMessageDialogWithLinkAndParams', keys, values, callbackName);
		}
		
		/**
		 * Open a Facebook dialog in a WebView
		 *
		 * @param method A dialog method (eg. login, feed...).
		 * @param parameters (Optional) An object (key-value pairs) containing the dialog parameters.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 */
		public function webDialog( method : String, parameters : Object = null, callback : Function = null ) : void
		{
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
			_context.call('webDialog', method, keys, values, callbackName);
		}

		/**
		 * Open a Facebook dialog.
		 * This method is kept for compatibility.
		 * If allowNativeUI is set to false this is equivalent to the method <code>webDialog</code>, else we try
		 * to call the correct native dialog based on given parameters and revert to <code>webDialog</code> if
		 * a native dialog cannot be used.
		 * 
		 * @param method A dialog method (eg. login, feed...).
		 * @param parameters (Optional) An object (key-value pairs) containing the dialog parameters.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
		 * object returned by Facebook.
		 * @param allowNativeUI (Optional) If true, we will try to use the native sharing dialog.
		 * Native sharing dialog will only be used if <code>method</code> is <em>feed</em> and <code>
		 * parameters</code> doesn't contain a non-empty <em>to</em> parameter. If the native sharing
		 * dialog can be used, only the following parameters will be used: name, picture, link, caption,
		 * description. Default is true.
		 */
		public function dialog( method : String, parameters : Object = null, callback : Function = null, allowNativeUI : Boolean = true ) : void
		{
			
			const isFeedDialog:Boolean = method == "feed";
			const hasRecipients:Boolean = parameters.hasOwnProperty("to");

			var useNativeShareUI:Boolean = isFeedDialog && allowNativeUI && !hasRecipients ;
			useNativeShareUI &&= canPresentShareDialog();

			if( useNativeShareUI )
			{
				shareLinkDialog( parameters['link'], parameters['name'], parameters['caption'], parameters['description'], parameters['picture'], callback );
			}
			else
			{
				webDialog( method, parameters, callback );
			}

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
		/**
		 * If <code>true</code>, logs will be displayed at the ActionScript level.
		 * If <code>false</code>, logs will be displayed only at the native level.
		 */
		public static var logEnabled : Boolean = false;

		private var _context : ExtensionContext;
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
			log("FACEBOOK about to call handleOpenURL on args: [" + event.arguments.join(",") + "] with reason: " + event.reason);

			if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				if (event.arguments != null && event.arguments.length > 0)
				{
					var url:String = event.arguments[0] as String;
					var sourceApplication:String = event.arguments[1] as String;
					var annotation:String = event.arguments[2] as String;

					_context.call("handleOpenURL", url, sourceApplication, annotation);
				}
			}
		}
		
		private function onStatus( event : StatusEvent ) : void
		{
			var today:Date = new Date();
			var callback:Function;

			log("onStatus " + event.code);

			if (event.code.indexOf("SESSION") != -1) // If the event code contains SESSION, it's an open/reauthorize session result
			{
				var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
				var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
				var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;
				
				if (event.code.indexOf("OPEN") != -1) callback = _openSessionCallback;
				else if (event.code.indexOf("REAUTHORIZE") != -1) callback = _reauthorizeSessionCallback;
				
				_openSessionCallback = null;
				_reauthorizeSessionCallback = null;

				var accessToken:FBAccessToken = _context.call('getAccessToken') as FBAccessToken;

				log(accessToken.toString());

				if(success){
					log("onStatus success: true callback:" + callback);
				}

				if (callback != null) callback(success, userCancelled, error);
			}
			else if (event.code == "ACTION_REQUIRE_PERMISSION")
			{
				dispatchEvent(new FacebookPermissionEvent(FacebookPermissionEvent.PERMISSION_NEEDED, event.level.split(',')));
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
//							if (accessToken != null)
//							{
//								data["accessToken"] = accessToken;
//							}
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
			if (Facebook.logEnabled){
				trace("[Facebook] " + message);
				_context.call('log', message);
			}
		}
	}
}
