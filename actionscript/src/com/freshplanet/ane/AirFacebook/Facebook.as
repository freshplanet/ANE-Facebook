package com.freshplanet.ane.AirFacebook
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
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
			return isIOS() || isAndroid();
		}

		private static function isIOS():Boolean
		{
			return Capabilities.version.indexOf("IOS") != -1;
		}

		private static function isAndroid():Boolean
		{
			return Capabilities.version.indexOf("AND") != -1;
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
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}

		private function onActivate(event:Event):void
		{
			if(isSupported && _context != null) {

				_context.call("activateApp");
			}
		}

		private function onDeactivate(event:Event):void
		{
			if(isSupported && _context != null && isAndroid()) {

				_context.call("deactivateApp");
			}
		}
		
		public static function getInstance() : Facebook
		{
			return _instance ? _instance : new Facebook();
		}
		
		/**
		 * Initialize the Facebook extension.
		 * 
		 * @param appID             A Facebook application ID (must be set for Android if there is missing FacebookId in application descriptor).
		 *
		 * <code>
		 *     <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="$FB_APP_ID"/>
		 * </code>
		 */
		public function init(appID:String = null) : void
		{
			if (!isSupported) return;
			
			_context.call('init', appID);
		}

		public function setDefaultShareDialogMode(shareDialogMode:FBShareDialogModeIOS):void
		{
			if (isSupported && _context != null && isIOS()){

				_context.call("setDefaultShareDialogMode", shareDialogMode.value);
			}
		}

		public function setLoginBehavior(loginBehavior:FBLoginBehaviorIOS):void
		{
			if (isSupported && _context != null && isIOS()){

				_context.call("setLoginBehavior", loginBehavior.value);
			}
		}

		public function setDefaultAudience(defaultAudience:FBLoginBehaviorIOS):void
		{
			if (isSupported && _context != null && isIOS()){

				_context.call("setDefaultAudience", defaultAudience.value);
			}
		}

		/**
		 * Fetches any deferred applink data and attempts to open the returned url
		 */
//		public function openDeferredAppLink() : void
//		{
//			if (!isSupported) return;
//
//			_context.call('openDeferredAppLink');
//		}
		
		/** True if a Facebook session is open, false otherwise. */
		public function get isSessionOpen() : Boolean
		{
			if (!isSupported) return false;

			return accessToken != null; //_context.call('isSessionOpen');
		}
		
		/** The current Facebook access token, or null if no session is open. */
		public function get accessToken():FBAccessToken
		{
			if (!isSupported) return null;

			var accessToken:FBAccessToken = _context.call('getAccessToken') as FBAccessToken;
			log(accessToken ? accessToken.toString() : "No access token!");
			return accessToken;
		}

		public function get profile():FBProfile
		{
			if (!isSupported) return null;

			var profile:FBProfile = _context.call('getProfile') as FBProfile;
			log(profile ? profile.toString() : "No profile!");
			return profile;
		}
		
		/**
		 * Open a new session with a given set of read permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #openSessionWithPublishPermissions()
		 */
		public function openSessionWithReadPermissions( permissions : Array, callback : Function = null) : void
		{
			openSessionWithPermissionsOfType(permissions, "read", callback);
		}

		/**
		 * Open a new session with a given set of publish permissions.<br><br>
		 * 
		 * @param permissions An array of requested <strong>publish</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #openSessionWithReadPermissions()
		 */
		public function openSessionWithPublishPermissions( permissions : Array, callback : Function = null) : void
		{
			openSessionWithPermissionsOfType(permissions, "publish", callback);
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
			contentUrl:String =null,
			contentTitle:String =null,
			contentDescription:String =null,
			imageUrl:String =null,
			useShareApi:Boolean =false,
			callback:Function =null ):void
		{

			_context.call('shareLinkDialog', contentUrl, contentTitle, contentDescription, imageUrl, useShareApi, getNewCallbackName(callback)) ;

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
		private var _requestCallbacks : Object = {};
		
		private function openSessionWithPermissionsOfType( permissions : Array, type : String, callback : Function = null ) : void
		{
			if (!isSupported) return;

			_openSessionCallback = callback;
			_context.call('openSessionWithPermissions', permissions, type);
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

				_openSessionCallback = null;

				var accessToken:FBAccessToken = _context.call('getAccessToken') as FBAccessToken;

				log(accessToken ? accessToken.toString() : "No access token!");

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
			else if (event.code.indexOf("SHARE") != -1)
			{
				var dataArr:Array = event.code.split("_");
				if(dataArr.length == 3){
					var status:String = dataArr[1];
					var callbackName:String = dataArr[2];

					callback = _requestCallbacks[callbackName];
				}
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
		
		private function log(message:String):void
		{
			if (Facebook.logEnabled){
				trace("[Facebook] " + message);
				_context.call('log', message);
			}
		}
	}
}
