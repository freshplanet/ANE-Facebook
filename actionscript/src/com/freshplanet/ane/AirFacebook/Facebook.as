/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.freshplanet.ane.AirFacebook {

    import com.freshplanet.ane.AirFacebook.appevents.FBEvent;
    import com.freshplanet.ane.AirFacebook.share.FBAppInviteContent;
    import com.freshplanet.ane.AirFacebook.share.FBGameRequestContent;
    import com.freshplanet.ane.AirFacebook.share.FBShareLinkContent;

    import flash.desktop.InvokeEventReason;

    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.InvokeEvent;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.net.URLRequestMethod;
    import flash.system.Capabilities;

    /**
     * todo
     */
    public class Facebook extends EventDispatcher {

        /**
         *
         */
        public static const VERSION:String = "4.19.0";

        /**
         * If <code>true</code>, logs will be displayed at the ActionScript level.
         */
        public static var logEnabled:Boolean = false;

        /**
         * If <code>true</code>, logs will be displayed at the native level.
         * You must change this before first call of getInstance() to actually see logs in native.
         */
        public static var nativeLogEnabled:Boolean = false;

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         *
         */
        public static function get isSupported():Boolean {
            return _isIOS() || _isAndroid();
        }

        /**
         *
         */
        public static function get instance():Facebook {
            return _instance ? _instance : new Facebook();
        }

        /**
         * Do not use this method outside this class. It may be removed anytime!
         *
         * @param message
         */
        public function log(message:String):void {

            if (Facebook.logEnabled)
                _as3Log(message, "AS3");

            if (Facebook.nativeLogEnabled)
                _nativeLog(message);
        }

        /**
         * Initialize the Facebook extension. Call any other method after onInitialized callback is called.
         *
         * @param appID             A Facebook application ID (must be set for Android if there is missing FacebookId in application descriptor).<br><br>
         * @param onInitialized     Called when Facebook SDK initialization is complete.
         * <code>
         *     &lt;meta-data android:name="com.facebook.sdk.ApplicationId" android:value="fb{YOUR_FB_APP_ID}"/&gt;
         * </code>
         *
         * NOTE: It is important to prefix YOUR_FB_APP_ID with "fb", because of bug in Android manifest file (http://stackoverflow.com/questions/16156856/android-facebook-applicationid-cannot-be-null).
         * Facebook SDK code in this ANE was modified to recognize FB_APP_ID prefixed with "fb".
         */
        public function init(appID:String = null,
                             onInitialized:Function = null):void {

            if (isSupported && _context != null) {

                _context.call("setNativeLogEnabled", Facebook.nativeLogEnabled);
                log("ANE Facebook version: " + VERSION);
                // iOS is synchronous but we will simulate async to have consistent API
                _context.call("initFacebook", appID, _getNewCallbackName(onInitialized));
            } else {

                log("Can't initialize extension! Unsupported platform or context couldn't be created!")
            }
        }

        /**
         * Sets default share dialog mode.
         *
         * @param shareDialogModeIOS
         * @param shareDialogModeAndroid
         *
         * @see com.freshplanet.ane.AirFacebook.FBShareDialogModeIOS
         * @see com.freshplanet.ane.AirFacebook.FBShareDialogModeAndroid
         */
        public function setDefaultShareDialogMode(shareDialogModeIOS:FBShareDialogModeIOS = null,
                                                  shareDialogModeAndroid:FBShareDialogModeAndroid = null):void {

            if (_isInitialized()) {

                if (_isIOS() && shareDialogModeIOS)
                    _context.call("setDefaultShareDialogMode", shareDialogModeIOS.value);
                else if (_isAndroid() && shareDialogModeAndroid)
                    _context.call("setDefaultShareDialogMode", shareDialogModeAndroid.value);
            }
        }

        /**
         * Sets default login behavior.
         *
         * @param loginBehaviorIOS
         * @param loginBehaviorAndroid
         *
         * @see com.freshplanet.ane.AirFacebook.FBLoginBehaviorIOS
         * @see com.freshplanet.ane.AirFacebook.FBLoginBehaviorAndroid
         */
        public function setLoginBehavior(loginBehaviorIOS:FBLoginBehaviorIOS = null,
                                         loginBehaviorAndroid:FBLoginBehaviorAndroid = null):void {

            if (_isInitialized()) {

                if (_isIOS() && loginBehaviorIOS)
                    _context.call("setLoginBehavior", loginBehaviorIOS.value);
                else if (_isAndroid() && loginBehaviorAndroid)
                    _context.call("setLoginBehavior", loginBehaviorAndroid.value);
            }
        }

        /**
         * Sets default audience for publish_actions.
         *
         * @param defaultAudience
         *
         * @see com.freshplanet.ane.AirFacebook.FBDefaultAudience
         */
        public function setDefaultAudience(defaultAudience:FBDefaultAudience = null):void {

            if (_isInitialized() && defaultAudience)
                _context.call("setDefaultAudience", defaultAudience.value);
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

        /**
         * The current Facebook access token, or null if no session is open.
         *
         * @see com.freshplanet.ane.AirFacebook.FBAccessToken
         */
        public function get accessToken():FBAccessToken {

            var accessToken:FBAccessToken = null;

            if (_isInitialized()) {

                accessToken = _context.call("getAccessToken") as FBAccessToken;
                log(accessToken ? accessToken.toString() : "No access token!");
            }

            return accessToken;
        }

        /**
         * Current Facebook profile, or null if no session is open.
         *
         * @see com.freshplanet.ane.AirFacebook.FBProfile
         */
        public function get profile():FBProfile {

            var profile:FBProfile = null;

            if (_isInitialized()) {

                profile = _context.call('getProfile') as FBProfile;
                log(profile ? profile.toString() : "No profile!");
            }

            return profile;
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
        public function logInWithReadPermissions(permissions:Array,
                                                 callback:Function = null):void {

            if (_isInitialized())
                _logIn(permissions, "read", callback);
        }

        /**
         * Open a new session with a given set of publish permissions.<br><br>
         *
         * @param permissions An array of requested <strong>publish</strong> permissions.
         * @param callback (Optional) A callback function of the following form:
         * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
         *
         * @see #logInWithReadPermissions()
         */
        public function logInWithPublishPermissions(permissions:Array,
                                                    callback:Function = null):void {

            if (_isInitialized())
                _logIn(permissions, "publish", callback);
        }

        /**
         * Closes the current Facebook session and delete the token from the cache.
         */
        public function logOut():void {

            if (_isInitialized())
                _context.call("logOut");
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
        public function requestWithGraphPath(graphPath:String,
                                             parameters:Object = null,
                                             httpMethod:String = URLRequestMethod.GET,
                                             callback:Function = null):void {

            if (_isInitialized()) {

                // Verify the HTTP method
                if (httpMethod != URLRequestMethod.GET &&
                    httpMethod != URLRequestMethod.POST &&
                    httpMethod != URLRequestMethod.DELETE) {

                    log("ERROR - Invalid HTTP method: " + httpMethod + " (must be GET, POST or DELETE)");
                    return;
                }

                // Separate parameters keys and values
                var keys:Array = [];
                var values:Array = [];

                for (var key:String in parameters) {

                    var value:String = parameters[key] as String;

                    if (value) {

                        keys.push(key);
                        values.push(value);
                    }
                }

                // Register the callback
                var callbackName:String = _getNewCallbackName(callback);

                // Execute the request
                _context.call("requestWithGraphPath", graphPath, keys, values, httpMethod, callbackName);
            }
        }

        /**
         * Determine if we can open a share dialog with current share dialog mode.
         * Call this method to decide what default share dialog mode you want to use.
         *
         * @see #setDefaultShareDialogMode
         */
        public function canPresentShareDialog():Boolean {

            var res:Boolean = false;

            if (_isInitialized())
                res = _context.call("canPresentShareDialog");

            return res;
        }

        /**
         * Shares a link. If useShareApi is set to true no dialog will be opened, otherwise you
         * can specify default share dialog mode by setting setDefaultShareDialogMode.
         *
         * @param shareLinkContent Content of share dialog.
         * @param useShareApi If you have publish_actions permission you can directly share through ShareAPI.
         * @param callback (Optional) A callback function of the following form:
         * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
         * object returned by Facebook.
         *
         * @see #setDefaultShareDialogMode
         */
        public function shareLinkDialog(shareLinkContent:FBShareLinkContent,
                                        useShareApi:Boolean = false,
                                        callback:Function = null):void {

            if (_isInitialized() && shareLinkContent != null)
                _context.call("shareLinkDialog", shareLinkContent, useShareApi, _getNewCallbackName(callback));
        }

        /**
         * Opens app invite dialog.
         *
         * @param appInviteContent Content of app invite dialog.
         * @param callback (TODO)
         */
        public function appInviteDialog(appInviteContent:FBAppInviteContent,
                                        callback:Function = null):void {

            if (_isInitialized() && appInviteContent != null)
                _context.call("appInviteDialog", appInviteContent, _getNewCallbackName(callback));
        }

        /**
         *
         * @param gameRequestContent
         * @param frictionless
         * @param callback
         */
        public function gameRequestDialog(gameRequestContent:FBGameRequestContent,
                                          frictionless:Boolean,
                                          callback:Function):void {

            if (_isInitialized() && gameRequestContent != null)
                _context.call("gameRequestDialog", gameRequestContent, frictionless, _getNewCallbackName(callback));
        }

        /**
         *
         * @param event
         */
        public function logEvent(event:FBEvent):void {

            if (_isInitialized())
                _context.call("logEvent", event);
        }

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									 	PRIVATE API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        private static const EXTENSION_ID:String = "com.freshplanet.ane.AirFacebook";

        private static var _instance:Facebook = null;

        private var _initialized:Boolean = false;
        private var _context:ExtensionContext = null;
        private var _openSessionCallback:Function = null;
        private var _requestCallbacks:Object = {};

        /**
         * "private" singleton constructor
         */
        public function Facebook() {

            super();

            if (_instance)
                throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");

            _instance = this;

            _context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);

            if (!_context)
                log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
            else {

                _context.addEventListener(StatusEvent.STATUS, _onStatus);

                NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, _onInvoke);
                NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, _onActivate);
                NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, _onDeactivate);
            }
        }

        /**
         *
         * @param permissions
         * @param type
         * @param callback
         */
        private function _logIn(permissions:Array, type:String, callback:Function = null):void {

            if (!isSupported)
                return;

            if (permissions == null)
                permissions = [];

            _openSessionCallback = callback;
            _context.call('logInWithPermissions', permissions, type);
        }

        /**
         *
         * @param callback
         * @return
         */
        private function _getNewCallbackName(callback:Function):String {

            // Generate callback name based on current time
            var date:Date = new Date();
            var callbackName:String = date.time.toString();

            // Clean up old callback if the name already exists
            if (_requestCallbacks.hasOwnProperty(callbackName))
                delete _requestCallbacks[callbackName];

            // Save new callback under this name
            _requestCallbacks[callbackName] = callback;

            return callbackName;
        }

        /**
         *
         * @param event
         */
        private function _onInvoke(event:InvokeEvent):void {

            //  NOTE: you can debug onInvoke with these lines of code
//            var debugStr:String;
//            if(event.reason == InvokeEventReason.NOTIFICATION) {
//                var obj:Object = event.arguments[0];
//                var arr:Array = [];
//                for (var prop in obj) {
//                    arr.push(prop + ": " + obj[prop]);
//                }
//                debugStr = arr.join(", ")
//            }else{
//                debugStr = event.arguments.join(",");
//            }
//
//            log("onInvoke reason: " + event.reason + " params: " + debugStr);

            if (Capabilities.manufacturer.indexOf("iOS") != -1) {

                if (event.reason == InvokeEventReason.OPEN_URL && event.arguments != null && event.arguments.length == 3) {

                    var url:String = event.arguments[0] as String;
                    var sourceApplication:String = event.arguments[1] as String;
                    var annotation:String = event.arguments[2] as String;

                    log("handleOpenURL url: " + url + " sourceApplication: " + sourceApplication + " annotation: " + annotation);
                    _context.call("handleOpenURL", url, sourceApplication, annotation);
                }
            }
        }

        /**
         *
         * @param event
         */
        private function _onStatus(event:StatusEvent):void {

            var dataArr:Array = null;
            var callbackName:String = null;
            var callback:Function = null;

            // If the event code contains SESSION, it's an open/reauthorize session result
            if (event.code == "LOGGING")
                _as3Log(event.level, "NATIVE");
            else if (event.code.indexOf("SESSION") != -1) {

                var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
                var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
                var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;

                callback = _openSessionCallback;
                _openSessionCallback = null;

                if (callback != null)
                    callback(success, userCancelled, error);
            }
            else if (event.code.indexOf("SHARE") != -1) {

                dataArr = event.code.split("_");

                if (dataArr.length == 3) {

                    var status:String = dataArr[1];
                    callbackName = dataArr[2];

                    callback = _requestCallbacks[callbackName];

                    if (callback != null) {

                        callback(status == "SUCCESS", status == "CANCELLED", status == "ERROR" ? event.level : null);

                        // TODO we should delete also null values from callback array
                        delete _requestCallbacks[callbackName];
                    }
                }
            }
            else if (event.code.indexOf("SDKINIT") != -1) {

                log("Facebook SDK initialized.");

                _initialized = true;

                dataArr = event.code.split("_");

                if (dataArr.length == 2) {

                    callbackName = dataArr[1];
                    callback = _requestCallbacks[callbackName];

                    if (callback != null) {

                        callback();

                        // TODO we should delete also null values from callback array
                        delete _requestCallbacks[callbackName];
                    }
                }
            }
            else { // Default case: we check for a registered callback associated with the event code

                if (_requestCallbacks.hasOwnProperty(event.code)) {

                    callback = _requestCallbacks[event.code];
                    var data:Object;

                    if (callback != null) {

                        try {
                            data = JSON.parse(event.level);
                        }
                        catch (e:Error) {
                            log("ERROR - " + e);
                        }

                        callback(data);

                        delete _requestCallbacks[event.code];
                    }
                }
            }
        }

        /**
         *
         * @param event
         */
        private function _onActivate(event:Event):void {

            if (isSupported && _context != null)
                _context.call("activateApp");
        }

        /**
         *
         * @param event
         */
        private function _onDeactivate(event:Event):void {

            if (isSupported && _context != null && _isAndroid())
                _context.call("deactivateApp");
        }

        /**
         *
         * @param message
         * @param prefix
         */
        private function _as3Log(message:String, prefix:String):void {
            trace("[AirFacebook][" + prefix + "] " + message);
        }

        /**
         *
         * @param message
         */
        private function _nativeLog(message:String):void {

            if (_context != null)
                _context.call('nativeLog', message);
        }

        /**
         *
         * @return
         */
        private function _isInitialized():Boolean {

            if (!_initialized) {

                log("You must call init() before any other method!");
                return false;
            }

            return true;
        }

        /**
         *
         * @return
         */
        private static function _isIOS():Boolean {
            return Capabilities.manufacturer.indexOf("iOS") > -1;
        }

        /**
         *
         * @return
         */
        private static function _isAndroid():Boolean {
            return Capabilities.manufacturer.indexOf("Android") > -1;
        }
    }
}