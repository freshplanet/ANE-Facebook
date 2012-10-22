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
		// 									   CONSTANTS										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const MAX_BATCH_ITEM:int = 20;
		
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		public static var URL_SUFFIX:String = "";
		
		public function Facebook()
		{
			if (!_instance)
			{
				if (isFacebookSupported)
				{
					_extCtx = ExtensionContext.createExtensionContext("com.freshplanet.AirFacebook", null);
					NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
					if (_extCtx != null)
					{
						_extCtx.addEventListener(StatusEvent.STATUS, onStatus);
					}
					else
					{
						trace('[Facebook] Error - Extension Context is null.');
					}
				}
				_instance = this;
			}
			else
			{
				throw Error('This is a singleton, use getInstance(), do not call the constructor directly.');
			}
		}
		
		public static function getInstance() : Facebook
		{
			return _instance ? _instance : new Facebook();
		}
		
		/** Get Facebook SSO access token (can be used for 2 months). */
		public function getAccessToken() : String
		{
			if (!isFacebookSupported) return null;
			
			return _extCtx.call('getAccessToken') as String;
		}
		
		/**
		 * Get expiration timestamp (in seconds since Unix epoch) associated with the current Facebook access token,
		 * or 0 if the session doesn't expire or doesn't exist.
		 */
		public function getExpirationTimestamp() : Number
		{
			if (!isFacebookSupported) return 0;
			
			return _extCtx.call('getExpirationTimestamp') as Number;
		}
		
		public function isLogIn() : Boolean
		{
			if (!isFacebookSupported) return false;
			
			return _extCtx.call('isSessionValid');
		}
		
		public function isLogOut() : Boolean
		{
			return !isLogIn();
		}
		
		public function deleteInvites() : void
		{
			requestWithGraphPath("me/apprequests", onAppRequestReceived);
		}
		
		public function get isFacebookSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf('iOS') > -1 || Capabilities.manufacturer.indexOf('Android') > -1;
		}
		
		public function initFacebook( appID : String ) : void
		{
			if (isFacebookSupported)
			{
				_extCtx.call('initFacebook', appID, URL_SUFFIX);
			}
		}
		
		public function extendAccessTokenIfNeeded() : void
		{
			if (isFacebookSupported)
			{
				_extCtx.call('extendAccessTokenIfNeeded');
			}
		}
		
		public function login( permissions : Array ) : void
		{
			if (isFacebookSupported)
			{
				_extCtx.call('login', permissions);
			}
		}
		
		public function askForMorePermissions( permissions : Array ) : void
		{
			if (isFacebookSupported)
			{
				_extCtx.call('askForMorePermissions', permissions);
			}
		}
		
		public function logout() : void
		{
			if (isFacebookSupported)
			{
				_extCtx.call('logout');
			}
		}
		
		/** 
		 * @param callback Will receive Facebook decoded JSON response.
		 * function(data:Object):void
		 */
		public function getUserInfo( callback : Function, customFields : Array = null ) : void
		{
			requestWithGraphPath("me", callback, customFields);
		}
		
		/** 
		 * @param callback Will receive Facebook decoded JSON response.
		 * function(data:Object):void
		 */
		public function getFriends( callback : Function, customFields : Array = null ) : void
		{
			requestWithGraphPath('me/friends', callback, customFields);
		}
		
		public function postOGAction( namespace : String, action : String, params : Object, callback : Function = null, method : String = "POST", prefix : String = "me/" ) : void
		{
			if (isFacebookSupported)
			{
				var nsAction:String;
				if (namespace == null || namespace == "")
				{
					nsAction = action;
				}
				else
				{
					nsAction = namespace+":"+action;
				}
				
				prefix = prefix ? prefix : "";
				var url:String = prefix + nsAction;
				
				var paramsKey:Array = [];
				var paramsValue:Array = [];
				for (var key:String in params)
				{
					paramsKey.push(key);
					paramsValue.push(params[key].toString());
				}
				
				trace('[Facebook] postOGAction ', "me/"+nsAction, paramsKey, paramsValue);
				
				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName];
				}
				_callbacks[callbackName] = callback;
				
				_extCtx.call('postOGAction', url, paramsKey, paramsValue, callbackName, method);
			}
		}
		
		public function postWithGraphApi( params : Object, facebookId : String = null ) : void
		{
			if (isFacebookSupported)
			{
				var paramsKey:Array = [];
				var paramsValue:Array = [];
				for (var key:String in params)
				{
					paramsKey.push(key);
					paramsValue.push(params[key].toString());
				}
				
				if (facebookId == null)
				{
					facebookId = "me";
				}
				
				trace('[Facebook] postOGAction ', facebookId+"/feed", paramsKey, paramsValue);
				_extCtx.call('postOGAction', facebookId+"/feed", paramsKey, paramsValue);
			}
		}
		
		/**
		 * Send invite requests to user friends.
		 * @param message message that will appear on request
		 * @param friendsArray array of friends.
		 * @param callback callback should expect an object. This object has the attribute params set when the
		 * invite is performed (i.e query string sent back by facebook), 
		 * @param data string sent as param
		 * cancel set to true if the invite is canceled, error set to the error description if sth went wrong.
		 */
		public function inviteFriends( message : String, friendsArray : Array = null, callback : Function = null, data : String = null ) : void
		{
			if (isFacebookSupported)
			{				
				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName]
				}
				_callbacks[callbackName] = callback;
				
				trace('[Facebook] openDialog - apprequests');
				var friendsString:String = friendsArray ? friendsArray.join() : null;
				_extCtx.call('openDialog', "apprequests", message, friendsString, callbackName, data);
			}
			else
			{
				if (callback != null)
				{
					callback(null);
				}
			}
		}
		
		/** Open a feed dialog to post the given message */
		public function post( message : String, name : String, picture : String, link : String, caption : String, description : String,
							  friendFacebookId : String = null, callback : Function = null ) : void
		{
			if (isFacebookSupported)
			{
				trace('[Facebook] openDialog - feed');
				
				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName]
				}
				_callbacks[callbackName] = callback;
				
				_extCtx.call('openFeedDialog', "feed", message, name, picture, link, caption, description, friendFacebookId, callbackName);
			}
			else
			{
				if (callback != null)
				{
					callback(null);
				}
			}
		}
		
		public function likeOnFacebookAction( params : Object, callback : Function = null ) : void
		{
			postOGAction(null, "og.likes", params, callback);
		}
		
		public function unlikeOnFacebookAction( actionId : String ) : void
		{
			postOGAction(null, actionId, null, null, "DELETE", null);
		}
		
		public function likePageOnFacebook( pageId : String, callback : Function = null ) : void
		{
			requestWithGraphPath("me/likes/" + pageId, callback); 
		}
		
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PRIVATE VARS										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static var _instance : Facebook;
		
		private var _extCtx : ExtensionContext;
		
		private var _callbacks : Object = {};
		
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 PRIVATE FUNCTIONS									 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private function onAppRequestReceived( object : Object ) : void
		{
			if (object && object.hasOwnProperty('data') && object['data'] != null)
			{
				var requestIdsToBeDeleted:Array = [];
				for each (var request:Object in object['data'])
				{
					if (request['id'] != null)
					{
						requestIdsToBeDeleted.push(String(request.id));
					}
					
					if (requestIdsToBeDeleted.length >= MAX_BATCH_ITEM)
					{
						break;
					}
				}
				
				if (isFacebookSupported && requestIdsToBeDeleted.length > 0)
				{
					_extCtx.call("deleteRequests", requestIdsToBeDeleted);
				}
			}
		}
		
		/** 
		 * @param graphPath Graph API object, like "me" or "me/friends"
		 * @param callback Will receive Facebook decoded JSON response. function(data:Object):void
		 * @param params list of fields
		 */
		private function requestWithGraphPath( graphPath : String, callback : Function, fields : Array = null ) : void
		{
			if(isFacebookSupported)
			{
				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName]
				}
				_callbacks[callbackName] = callback;
				
				var params:String;
				if (fields != null && fields.length > 0)
				{
					params = fields.join();
				}
				
				trace('[Facebook] requestWithGraphPath ', graphPath, params);
				_extCtx.call('requestWithGraphPath', callbackName, graphPath, params);
			}
			else
			{
				callback(null);
			}
		}
		
		private function onInvoke( event : InvokeEvent ) : void
		{
			if (event.arguments != null && event.arguments.length > 0)
			{
				if (isFacebookSupported)
				{
					_extCtx.call("handleOpenURL", String(event.arguments[0]));
				}
			}
		}
		
		private function onStatus( event : StatusEvent ) : void
		{
			var e:FacebookEvent;
			var today:Date = new Date();
			
			switch (event.code)
			{
				case 'USER_LOGGED_IN':
				case 'ACCESS_TOKEN_REFRESHED':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_IN_SUCCESS_EVENT);
					break;
				case 'USER_LOGGED_OUT':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_OUT_SUCCESS_EVENT);
					break;
				case 'USER_LOG_IN_CANCEL':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_IN_CANCEL_EVENT);
					break;
				case 'USER_LOG_IN_FB_ERROR':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_IN_FACEBOOK_ERROR_EVENT);
					e.message = event.level;
					break;
				case 'USER_LOG_IN_ERROR':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_IN_ERROR_EVENT);
					e.message = event.level;
					break;
				case 'LOGGING':
					trace("[Facebook] " + event.level);
					break;
				case 'DELETE_INVITE':
					trace("[Facebook] Delete Invite - ", event.level);
					break;
				default:
					if (_callbacks.hasOwnProperty(event.code))
					{
						var callback:Function = _callbacks[event.code];
						var data:Object;
						
						if (callback != null)
						{
							try
							{
								data = JSON.parse(event.level);
								if (getAccessToken() != null)
								{
									data['accessToken'] = getAccessToken();
								}
							}
							catch (e:Error)
							{
								trace("[Facebook] Error - ", e);
							}
							
							callback(data);
							
							delete _callbacks[event.code];
						}
					}
			}
			
			if (e) dispatchEvent(e);
		}
	}
}