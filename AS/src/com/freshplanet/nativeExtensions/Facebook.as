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
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.system.System;

	public class Facebook extends EventDispatcher
	{
		
		private static const FILE_URI:String = "com.freshplanet.facebook.token.information.file";

		private static var _instance:Facebook;

		private var extCtx:ExtensionContext = null;
		
		private var accessToken:String;
		private var expirationTimeStamp:String;
		private var lastAccessTokenTimeStamp:int;
		
		private var cacheDir:File;

		
		private function getCacheDirectory():File
		{
			if (cacheDir != null)
			{
				return cacheDir;
			}
			
			if (Capabilities.manufacturer.indexOf("iOS") > -1)
			{
				var str:String = File.applicationDirectory.nativePath;
				cacheDir= new File(str +"/\.\./Library/Caches");
			} else
			{
				cacheDir = File.applicationStorageDirectory;
			}
			
			return cacheDir;
		}

		
		
		private function storeTokenInfo(newAccessToken:String, newExpirationTime:String):void
		{
			this.accessToken = newAccessToken;
			this.expirationTimeStamp = newExpirationTime;
			
			var object:Object = {'access_token': accessToken, 'expiration_timestamp': expirationTimeStamp};
			
			trace('store : '+object.toString());
			
			//create a file under the application storage folder
			var file:File = getCacheDirectory().resolvePath(FILE_URI);
			
			var fileStream:FileStream = new FileStream(); //create a file stream
			fileStream.open(file, FileMode.WRITE);// and open the file for write
			fileStream.writeObject(object);//write the object to the file
			fileStream.close();
			trace('stored :', accessToken,', ',expirationTimeStamp);

		}
		
		
		public function isLogIn():Boolean
		{
			return this.accessToken != null;
		}
		
		
		public function isLogOut():Boolean
		{
			//todo;
			return false;
		}
		
		public function deleteInvites():void
		{
			//todo
			if (this.isFacebookSupported)
			{
				this.requestWithGraphPath("me/apprequests", null, onAppRequestReceived);
				// call getAppRequests, removeAppRequests([request_ids])
			}

		}
		
		private static const MAX_BATCH_ITEM:int = 20;
		
		private function onAppRequestReceived(object:Object):void
		{
			trace(object);
			if (object && object.hasOwnProperty('data') && object['data'] != null)
			{
				var requestIdsToBeDeleted:Array = [];
				for each(var request:Object in object['data'])
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
				if (this.isFacebookSupported && requestIdsToBeDeleted.length > 0)
				{
					extCtx.call("deleteRequests", requestIdsToBeDeleted);
				}
			}
		}
		
		private function loadTokenInfo():void
		{
			trace('load token info');
			var file:File = getCacheDirectory().resolvePath(FILE_URI);
			if (!file.exists) {
				return;
			}
			
			//create a file stream and open it for reading
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var object:Object = fileStream.readObject(); //read the object
			trace('load : '+object.toString());

			if (object != null && object.hasOwnProperty('access_token'))
			{
				this.accessToken = object['access_token'];
				if (object.hasOwnProperty('expiration_timestamp'))
				{
					this.expirationTimeStamp = object['expiration_timestamp'];
				}
				trace('loaded ', this.accessToken, this.expirationTimeStamp);
			}
		}
		
		private function deleteTokenInfo():void
		{
			this.accessToken = null;
			this.expirationTimeStamp = null;
			trace('delete : '+{}.toString());

			var file:File = getCacheDirectory().resolvePath(FILE_URI);
			if (!file.exists) {
				return;
			} else
			{
				file.deleteFile();
			}
		}
		
		
		
		
		
		public function Facebook()
		{
			if (!_instance)
			{
				if (this.isFacebookSupported)
				{
					extCtx = ExtensionContext.createExtensionContext("com.freshplanet.AirFacebook", null);
					NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
					if (extCtx != null)
					{
						extCtx.addEventListener(StatusEvent.STATUS, onStatus);
					} else
					{
						trace('extCtx is null.');
					}
				}
				_instance = this;
			}
			else
			{
				throw Error( 'This is a singleton, use getInstance, do not call the constructor directly');
			}
		}
		
		
		public static function getInstance() : Facebook
		{
			return _instance ? _instance : new Facebook();
		}

		public function get isFacebookSupported():Boolean
		{
			var result:Boolean = Capabilities.manufacturer.indexOf('iOS') > -1 || Capabilities.manufacturer.indexOf('Android') > -1;
			trace(result ? 'Facebook is supported' : 'Facebook is not supported');
			return result;
		}
		
		/**
		 * Init Facebook Library.
		 */
		public function initFacebook(facebookId:String):void
		{
			if (this.isFacebookSupported)
			{
				this.loadTokenInfo();
				trace('initializing Facebook Library '+facebookId+' access '+this.accessToken+' expires '+this.expirationTimeStamp);
				extCtx.call('initFacebook', facebookId, this.accessToken, this.expirationTimeStamp);
			}
		}
		
		
		public function extendAccessTokenIfNeeded():void
		{
			if (this.isFacebookSupported)
			{
				if (shouldRefreshSession)
				{
					extCtx.call('extendAccessTokenIfNeeded');
				}
			}
		}
		
		
		/**
		 * Try to log the user in.
		 */
		public function login(permissions:Array):void
		{
			if (this.isFacebookSupported)
			{
				trace('logging in to the Facebook App.');
				
				if (!isSessionValid)
				{
					trace('session invalid');
					extCtx.call('login', permissions);
				} else
				{
					if (shouldRefreshSession) // expiration time is about to be done
					{
						trace('session needs to be refreshed');
						this.extendAccessTokenIfNeeded();
						
					} else
					{
						trace('session valid');
						this.dispatchEvent(new FacebookEvent(FacebookEvent.USER_LOGGED_IN_SUCCESS_EVENT));
					}
				}
			}
		}

		
		
		public function logout():void
		{
			if (this.isFacebookSupported)
			{
					extCtx.call('logout');
			}
		}
		
		
		private static const REFRESH_TOKEN_BARRIER:int = 24 * 60 * 60 * 1000; // access_token has less than 24 hours to live
		
		
		private function get shouldRefreshSession():Boolean
		{
			var today:Date = new Date();
			return this.isSessionValid && lastAccessTokenTimeStamp > 0 && today.time - lastAccessTokenTimeStamp >= REFRESH_TOKEN_BARRIER;
		}
		
		
		
		private function get isSessionValid():Boolean
		{
			var today:Date = new Date();
			trace('tokenInfo : '+this.accessToken + ' - ' + this.expirationTimeStamp + ' - '+today.time);
			return this.accessToken != null && (this.expirationTimeStamp != null && Number(this.expirationTimeStamp) > today.time);
		}
		
		
		private var _callbacks:Object = {};
		
		public function getUserInfo(callback:Function):void
		{
			if (this.isFacebookSupported)
			{
				trace('Get User Info');
				requestWithGraphPath("me", null, callback);
			} else
			{
				callback(null);
			}
		}
		
		/**
		 * Post a message to user wall. 
		 * @param message message used (it is currently not supported by fb)
		 * @param callback callback should expect an object. This object has the attribute params set when the post is performed (i.e query string sent back by facebook), 
		 * cancel set to true if the post is canceled, error set to the error description if sth went wrong.
		 * 
		 */
		public function post(message:String, callback:Function = null):void
		{
			if (this.isFacebookSupported)
			{
				trace('post message', message);

				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName]
				}
				_callbacks[callbackName] = callback;

				extCtx.call('openDialog', "feed", message, null, callbackName);
			} else
			{
				if (callback != null)
				{
					callback(null);
				}
			}

		}
		
		private function requestWithGraphPath(graphPath:String, params:String, callback:Function):void
		{
			var date:Date = new Date();
			var callbackName:String = date.time.toString();
			if (_callbacks.hasOwnProperty(callbackName))
			{
				delete _callbacks[callbackName]
			}
			_callbacks[callbackName] = callback;
			trace('graphPath '+graphPath);
			extCtx.call('requestWithGraphPath', callbackName, graphPath, params);
		}
		
		
		public function getFriends(callback:Function, customFields:Array = null):void
		{
			if (this.isFacebookSupported)
			{
				trace('getting Facebook friends');
				var url:String = 'me/friends';
				
				var param:String = null;
				
				if (customFields != null && customFields.length > 0)
				{
					param = customFields.join();
				}
				requestWithGraphPath(url, param, callback);
			} else
			{
				callback(null);
			}
		}
		
		
		/**
		 * Get Facebook SSO access token (can be used for 2 months) 
		 * @return 
		 * 
		 */
		public function getAccessToken():String
		{
			return this.accessToken;
		}
		
		
		
		/**
		 * Get Expiration timestamp (in seconds) associated with the current Facebook Access Token.
		 * @return 
		 * 
		 */
		public function getExpirationTimestamp():Number
		{
			return this.expirationTimeStamp != null ?  Number(this.expirationTimeStamp) : 0;
		}
		

		
		
		/**
		 * Send invite requests to user friends.
		 * @param message message that will appear on request
		 * @param friendsArray array of friends.
		 * @param callback callback should expect an object. This object has the attribute params set when the invite is performed (i.e query string sent back by facebook), 
		 * cancel set to true if the invite is canceled, error set to the error description if sth went wrong.
		 * 
		 */
		public function inviteFriends(message:String, friendsArray:Array = null, callback:Function = null):void
		{
			if (this.isFacebookSupported)
			{				
				var date:Date = new Date();
				var callbackName:String = date.time.toString();
				if (_callbacks.hasOwnProperty(callbackName))
				{
					delete _callbacks[callbackName]
				}
				_callbacks[callbackName] = callback;

				trace('inviting Facebook friends', message);
				if (friendsArray != null)
				{
					extCtx.call('openDialog', "apprequests", message, friendsArray.join(), callbackName);
				} else
				{
					extCtx.call('openDialog', "apprequests", message, null, callbackName);
				}
			} else
			{
				if (callback != null)
				{
					callback(null);
				}
			}
		}
		
		private function onInvoke(event:InvokeEvent):void
		{
			if (event.arguments != null && event.arguments.length > 0)
			{
				if (this.isFacebookSupported)
				{
					extCtx.call('handleOpenURL', String(event.arguments[0]));
				}
			}
		}
		
		
		
		private function onStatus(event:StatusEvent):void
		{
			trace('fb status '+event);
			var e:FacebookEvent;
			var today:Date = new Date();
			switch (event.code)
			{
				case 'USER_LOGGED_IN':
				case 'ACCESS_TOKEN_REFRESHED':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_IN_SUCCESS_EVENT);
					var msg:String = event.level;
					var msgArray:Array = msg.split('&');
					this.storeTokenInfo(msgArray[0], msgArray[1]);
					lastAccessTokenTimeStamp = today.time;
					break;
				case 'USER_LOGGED_OUT':
					e = new FacebookEvent(FacebookEvent.USER_LOGGED_OUT_SUCCESS_EVENT);
					this.deleteTokenInfo();
					lastAccessTokenTimeStamp = 0;
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
					trace(event.level);
					break;
				case 'DELETE_INVITE':
					trace(event.level);
					break;
				default:
					if (_callbacks.hasOwnProperty(event.code))
					{
						var callback:Function = _callbacks[event.code];
						var data:Object;
						lastAccessTokenTimeStamp = today.time;
						try {
							data = JSON.parse(event.level);
							if (this.accessToken != null)
							{
								data['accessToken'] = this.accessToken;
							}
						} catch (e:Error)
						{
							trace(e);
						}
						if (callback != null)
						{
							callback(data);
						}
						delete _callbacks[event.code];
					}
			}
			if (e != null)
			{
				this.dispatchEvent(e);
			}
		}
		
	}
}