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
	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.core.FacebookURLDefaults;
import com.facebook.graph.data.FacebookSession;

import flash.display.Stage;

	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;

//	import starling.core.Starling;

	public class Facebook extends EventDispatcher
	{
		private var _redirectUrl:String;
		private var _stage:Stage;
		private var onInitialized:Function;
		private var _appID:String;

		public static function get isSupported() : Boolean
		{
			return true;
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

		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 * If <code>false</code>, logs will be displayed only at the native level.
		 */
		public function get logEnabled() : Boolean
		{
			return _logEnabled;
		}

		public function set stage(stage:Stage) : void {
			this._stage = stage;
		}

		/**
		 * This is only important on Android - if you are using stage3D for display at the time you log in to FB,
		 * set this to true to avoid the display freezing
		 */
		public function setUsingStage3D(using3d:Boolean) : void 
		{
		}

		public function set logEnabled( value : Boolean ) : void
		{
			_logEnabled = value;
		}

		/**
		 * Initialize the Facebook extension.
		 *
		 * @param appID             A Facebook application ID.
		 * @param legacyMode        TRUE enables Graph 1.0, FALSE uses current Graph API.
		 * @param urlSchemeSuffix   (Optional) The URL Scheme Suffix to be used in scenarios where multiple iOS apps
		 *                          use one Facebook App ID. Must contain only lowercase letters.
		 */
		public function init( appID : String, onInitialized:Function = null, redirectUrl:String = null ) : void
		{
			this.onInitialized = onInitialized;
			_redirectUrl = redirectUrl;
			FacebookURLDefaults.LOGIN_SUCCESS_URL = _redirectUrl;
			FacebookURLDefaults.LOGIN_SUCCESS_SECUREURL = _redirectUrl;
			_appID = appID;
			FacebookMobile.init(appID, onFacebookInit);
		}

		/** True if a Facebook session is open, false otherwise. */
		public function get isSessionOpen() : Boolean
		{
			return sessionOpened;
		}

		/** The current Facebook user id, or null if no session is open. */
		public function get userId() : String
		{
			return _userId;
		}

		/**
		 * Open a new session with a given set of read permissions.<br><br>
		 *
		 * @param permissions An array of requested <strong>read</strong> permissions.
		 * @param callback (Optional) A callback function of the following form:
		 * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
		 *
		 * @see #logInWithPublishPermissions()
		 */
		public function logInWithReadPermissions(permissions:Array, callback:Function = null):void
		{
			if (_initialized) {

				_openSessionCallback = callback;
				var stageWebView:StageWebView = new StageWebView();

				stageWebView.stage = _stage;

				stageWebView.viewPort = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
				FacebookMobile.login(onFacebookLogin, _stage, permissions, stageWebView);
			} else {

				log("You must call init() before any other method!");
			}
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
		public function openSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			_openSessionCallback = callback;
			var stageWebView:StageWebView = new StageWebView();
			
			stageWebView.stage = _stage;

			stageWebView.viewPort = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
			FacebookMobile.login(onFacebookLogin, _stage, null, stageWebView);
		}

		/**
		 * Closes the current Facebook session and delete the token from the cache.
		 */
		public function logOut():void
		{
			if (_initialized) {
				FacebookMobile.logout(onFacebookLoggedOut, _redirectUrl);
			} else {

				log("You must call init() before any other method!");
			}
		}

		public function printStuff() : void
		{
			log("Printing stuff");
		}

		public function trackCompletedFacebookRegistration() : void {
			log("trackCompletedFacebookRegistration");
		}

		public function trackCustomEvent(event:String) : void {
			log("trackCustomEvent: " + event);

		}

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

		private var sessionOpened:Boolean;
		private var _openSessionCallback : Function;
		private var _userId:String
		private static var _instance : Facebook;
		private var _logEnabled : Boolean = true;
		private var _initialized:Boolean = false;
		private var _profile:FBProfile;
		private var _accessToken:FBAccessToken;

		private function onFacebookInit(success:FacebookSession, fail:Object):void {
			_initialized = true;
			if(success) {
				log("Logged in to Facebook");
				_userId = success["uid"];

				setAccessTokenFromSession(success);

				setProfileFromSession(success);

				FacebookMobile.api("/me", onPermissionsReceived, {fields: "permissions"});
				sessionOpened = true;
			} 
			else {
				log("You need to login to Facebook");
			}

		}

		private function onPermissionsReceived(result:Object, fail:Object):void {
			if(result) {
				for each(var permission:Object in result.permissions.data) {
					accessToken.permissions.push(permission.permission);
				}
			} else {
				log("Error, failed to get granted permissions: " + JSON.stringify(fail));
			}
			onInitialized();
		}

		private function setProfileFromSession(success:FacebookSession):void{
                    profile = new FBProfile();
                    profile.userID = _userId;
                    profile.firstName = success.user.first_name;
                    profile.lastName = success.user.last_name;
                    profile.middleName = success.user.middle_name;
                    profile.name = success.user.name;
                    profile.linkUrl = success.user.link;
                }

		private function setAccessTokenFromSession(success:FacebookSession):void{
                    accessToken = new FBAccessToken();
                    accessToken.tokenString = success.accessToken;
                    accessToken.appID = _appID;
                    accessToken.declinedPermissions = [];
                    accessToken.permissions = [];
                    accessToken.expirationDate = success.expireDate.date;
                    accessToken.refreshDate = new Date().date;
                    accessToken.userID = _userId;
                }

		public function set accessToken(accessToken:FBAccessToken):void {
			_accessToken = accessToken;
		}

		public function set profile(profile:FBProfile):void {
			_profile = profile;
		}

		/**
		 * Current Facebook profile, or null if no session is open.
		 *
		 * @see com.freshplanet.ane.AirFacebook.FBProfile
		 */
		public function get profile():FBProfile
		{
			if (_initialized) {
				return _profile;
			} else {

				log("You must call init() before any other method!");
				return null;
			}
		}

		/**
		 * The current Facebook access token, or null if no session is open.
		 *
		 * @see com.freshplanet.ane.AirFacebook.FBAccessToken
		 */
		public function get accessToken():FBAccessToken
		{
			if (_initialized) {
				return _accessToken;
			} else {

				log("You must call init() before any other method!");
				return null;
			}
		}

		private function onFacebookLogin(success:FacebookSession, fail:Object):void {
			if(success) {
				log("Logged in to Facebook");
				_userId = success["uid"];

				log(String(JSON.stringify(success.availablePermissions)));

				setAccessTokenFromSession(success);

				setProfileFromSession(success);

				_openSessionCallback(true, false, null);
			} 
			else {
				log("Failed logging in to Facebook");
				_openSessionCallback(false, false, "ERROR");
			}
		}

		private function onFacebookLoggedOut(success:Boolean):void {
			if(success) {
				profile = null;
				accessToken = null;
				log("Logged out from Facebook");
			} 
			else {
				log("Failed logging out from Facebook");
			}			
		}


		private function log( message : String ) : void
		{
			if (_logEnabled) { 
				trace("[Facebook] " + message);
				dispatchEvent(new FacebookLogEvent(FacebookLogEvent.LOG, message));
			}
		}
	}
}


