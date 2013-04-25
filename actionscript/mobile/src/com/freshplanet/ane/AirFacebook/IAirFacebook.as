package com.freshplanet.ane.AirFacebook
{
	public interface IAirFacebook
	{
		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 * If <code>false</code>, logs will be displayed only at the native level.
		 */
		function get logEnabled() : Boolean;
		function set logEnabled( value : Boolean ) : void
		
		/**
		 * Initialize the Facebook extension.
		 * 
		 * @param appID A Facebook application ID.
		 * @param urlSchemeSuffix (Optional) The URL Scheme Suffix to be used in scenarios where multiple iOS apps
		 * use one Facebook App ID. Must contain only lowercase letters.
		 */
		function init( appID : String, urlSchemeSuffix : String = null ) : void;
		
		/** True if a Facebook session is open, false otherwise. */
		function get isSessionOpen() : Boolean;
		
		/** The current Facebook access token, or null if no session is open. */
		function get accessToken() : String;
		
		/**
		 * The expiration timestamp (in seconds since Unix epoch) associated with the current Facebook access token,
		 * or 0 if the session doesn't expire or doesn't exist.
		 */
		function get expirationTimestamp() : Number;
		
		/**
		 * Open a new session with a given set of read permissions.<br><br>
		 * 
		 * On iOS 6, this method triggers the native authentication flow.
		 * 
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * If this array contains a publish permissions, the login will fail on iOS.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #openSessionWithPublishPermissions()
		 * @see #openSessionWithPermissions()
		 */
		function openSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void;
		
		/**
		 * Open a new session with a given set of publish permissions.<br><br>
		 * 
		 * On iOS 6, this method triggers the native authentication flow.
		 * 
		 * @param permissions An array of requested <strong>publish</strong> permissions.
		 * If this array contains a read permissions, the login will fail on iOS.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #openSessionWithReadPermissions()
		 * @see #openSessionWithPermissions()
		 */
		function openSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void;
		
		/**
		 * Open a new session with a given set of permissions.<br><br>
		 * 
		 * On iOS, this method uses the old app-switching or web-based authentication
		 * flow (even on iOS 6).
		 * 
		 * @param permissions An array of requested permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #openSessionWithReadPermissions()
		 * @see #openSessionWithPublishPermissions()
		 */
		function openSessionWithPermissions( permissions : Array, callback : Function = null ) : void;
		
		/**
		 * Reauthorize the current session with a given set of read permissions.<br><br>
		 * 
		 * On iOS 6, this method triggers the native authentication flow.
		 * 
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * If this array contains a publish permissions, the app will crash on iOS.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #reauthorizeSessionWithPublishPermissions()
		 */
		function reauthorizeSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void;
		
		/**
		 * Reauthorize the current session with a given set of publish permissions.<br><br>
		 * 
		 * On iOS 6, this method triggers the native authentication flow.
		 * 
		 * @param permissions An array of requested <strong>publish</strong> permissions.
		 * If this array contains a read permissions, the app will crash on iOS.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 * 
		 * @see #reauthorizeSessionWithReadPermissions()
		 */
		function reauthorizeSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void;
		
		/** Close the current Facebook session and delete the token from the cache. */
		function closeSessionAndClearTokenInformation() : void;
		
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
		function requestWithGraphPath( graphPath : String, parameters : Object = null, httpMethod : String = "GET", callback : Function = null ) : void;
		
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
		function dialog( method : String, parameters : Object = null, callback : Function = null, allowNativeUI : Boolean = true ) : void;
		
		/** Register the appId for install tracking. Works only on iOS now*/
		function publishInstall( appId:String ):void;
		
	}
}
