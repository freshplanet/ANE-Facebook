package com.freshplanet.ane.AirFacebook {

import com.freshplanet.ane.AirFacebook.appevents.FBEvent;
import com.freshplanet.ane.AirFacebook.share.FBAppInviteContent;
import com.freshplanet.ane.AirFacebook.share.FBGameRequestContent;
import com.freshplanet.ane.AirFacebook.share.FBShareLinkContent;

import flash.desktop.InvokeEventReason;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.InvokeEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;

public class Facebook extends EventDispatcher {

    public static const VERSION:String = "4.5.2";

    private var _initialized:Boolean;

    // --------------------------------------------------------------------------------------//
    //																						 //
    // 									   PUBLIC API										 //
    // 																						 //
    // --------------------------------------------------------------------------------------//

    /** Facebook is supported on iOS and Android devices. */
    public static function get isSupported():Boolean
    {
        return isIOS() || isAndroid();
    }

    private static function isIOS():Boolean
    {
        return Capabilities.manufacturer.indexOf("iOS") > -1;
    }

    private static function isAndroid():Boolean
    {
        return Capabilities.manufacturer.indexOf("Android") > -1;
    }

    public function Facebook()
    {
        if (!_instance) {

            _instance = this;

            _context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
            if (!_context) {
                log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
                return;
            }
            _context.addEventListener(StatusEvent.STATUS, onStatus);

            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);

        }
        else {
            throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
        }
    }

    private function onActivate(event:Event):void
    {
        if (isSupported && _context != null) {

            _context.call("activateApp");
        }
    }

    private function onDeactivate(event:Event):void
    {
        if (isSupported && _context != null && isAndroid()) {

            _context.call("deactivateApp");
        }
    }

    public static function getInstance():Facebook
    {
        return _instance ? _instance : new Facebook();
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
    public function init(appID:String = null, onInitialized:Function = null):void
    {
        if (isSupported && _context != null) {

            _context.call("setNativeLogEnabled", Facebook.nativeLogEnabled);
            log("ANE Facebook version: " + VERSION);
            // iOS is synchronous but we will simulate async to have consistent API
            _context.call("initFacebook", appID, getNewCallbackName(onInitialized));
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
                                              shareDialogModeAndroid:FBShareDialogModeAndroid = null):void
    {
        if (_initialized) {

            if (isIOS() && shareDialogModeIOS) {

                _context.call("setDefaultShareDialogMode", shareDialogModeIOS.value);
            } else if (isAndroid() && shareDialogModeAndroid) {

                _context.call("setDefaultShareDialogMode", shareDialogModeAndroid.value);
            }
        } else {

            log("You must call init() before any other method!");
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
                                     loginBehaviorAndroid:FBLoginBehaviorAndroid = null):void
    {
        if (_initialized) {

            if (isIOS() && loginBehaviorIOS) {

                _context.call("setLoginBehavior", loginBehaviorIOS.value);
            } else if (isAndroid() && loginBehaviorAndroid) {

                _context.call("setLoginBehavior", loginBehaviorAndroid.value);
            }
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Sets default audience for publish_actions.
     *
     * @param defaultAudience
     *
     * @see com.freshplanet.ane.AirFacebook.FBDefaultAudience
     */
    public function setDefaultAudience(defaultAudience:FBDefaultAudience = null):void
    {
        if (_initialized) {

            if(defaultAudience) {

                _context.call("setDefaultAudience", defaultAudience.value);
            }
        } else {

            log("You must call init() before any other method!");
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

    /**
     * The current Facebook access token, or null if no session is open.
     *
     * @see com.freshplanet.ane.AirFacebook.FBAccessToken
     */
    public function get accessToken():FBAccessToken
    {
        if (_initialized) {

            var accessToken:FBAccessToken = _context.call("getAccessToken") as FBAccessToken;
            log(accessToken ? accessToken.toString() : "No access token!");
            return accessToken;
        } else {

            log("You must call init() before any other method!");
            return null;
        }
    }

    /**
     * Current Facebook profile, or null if no session is open.
     *
     * @see com.freshplanet.ane.AirFacebook.FBProfile
     */
    public function get profile():FBProfile
    {
        if (_initialized) {

            var profile:FBProfile = _context.call('getProfile') as FBProfile;
            log(profile ? profile.toString() : "No profile!");
            return profile;
        } else {

            log("You must call init() before any other method!");
            return null;
        }
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

            logIn(permissions, "read", callback);
        } else {

            log("You must call init() before any other method!");
        }
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
    public function logInWithPublishPermissions(permissions:Array, callback:Function = null):void
    {
        if (_initialized) {

            logIn(permissions, "publish", callback);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Closes the current Facebook session and delete the token from the cache.
     */
    public function logOut():void
    {
        if (_initialized) {

            _context.call("logOut");
        } else {

            log("You must call init() before any other method!");
        }
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
    public function requestWithGraphPath(graphPath:String, parameters:Object = null, httpMethod:String = "GET", callback:Function = null):void
    {
        if (_initialized) {

            // Verify the HTTP method
            if (httpMethod != "GET" && httpMethod != "POST" && httpMethod != "DELETE") {
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
            var callbackName:String = getNewCallbackName(callback);

            // Execute the request
            _context.call("requestWithGraphPath", graphPath, keys, values, httpMethod, callbackName);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Determine if we can open a share dialog with current share dialog mode.
     * Call this method to decide what default share dialog mode you want to use.
     *
     * @see #setDefaultShareDialogMode
     */
    public function canPresentShareDialog():Boolean
    {
        if (_initialized) {

            return _context.call("canPresentShareDialog");
        } else {

            log("You must call init() before any other method!");
            return false;
        }
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
                                    callback:Function = null):void
    {
        if (_initialized) {

            if(shareLinkContent == null){
                return;
            }
            _context.call("shareLinkDialog", shareLinkContent, useShareApi, getNewCallbackName(callback));
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Opens app invite dialog.
     *
     * @param appInviteContent Content of app invite dialog.
     * @param callback (TODO)
     */
    public function appInviteDialog(appInviteContent:FBAppInviteContent, callback:Function = null):void
    {
        if (_initialized) {

            if(appInviteContent == null){
                return;
            }
            _context.call("appInviteDialog", appInviteContent, getNewCallbackName(callback));
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     *
     * @param gameRequestContent
     * @param callback
     */
    public function gameRequestDialog(gameRequestContent:FBGameRequestContent, frictionless:Boolean, callback:Function):void
    {
        if (_initialized) {

            if(gameRequestContent == null){
                return;
            }
            _context.call("gameRequestDialog", gameRequestContent, frictionless, getNewCallbackName(callback));
        } else {

            log("You must call init() before any other method!");
        }
    }

    public function logEvent(event:FBEvent):void
    {
        if(_initialized){

            _context.call("logEvent", event);
        } else {

            log("You must call init() before any other method!");
        }
    }

    // --------------------------------------------------------------------------------------//
    //																						 //
    // 									 	PRIVATE API										 //
    // 																						 //
    // --------------------------------------------------------------------------------------//

    private static const EXTENSION_ID:String = "com.freshplanet.ane.AirFacebook";

    private static var _instance:Facebook;
    /**
     * If <code>true</code>, logs will be displayed at the ActionScript level.
     */
    public static var logEnabled:Boolean = false;
    /**
     * If <code>true</code>, logs will be displayed at the native level.
     * You must change this before first call of getInstance() to actually see logs in native.
     */
    public static var nativeLogEnabled:Boolean = false;

    private var _context:ExtensionContext;
    private var _openSessionCallback:Function;
    private var _requestCallbacks:Object = {};

    private function logIn(permissions:Array, type:String, callback:Function = null):void
    {
        if (!isSupported) return;

        _openSessionCallback = callback;
        if(permissions == null) permissions = [];
        _context.call('logInWithPermissions', permissions, type);
    }

    private function getNewCallbackName(callback:Function):String
    {
        // Generate callback name based on current time
        var date:Date = new Date();
        var callbackName:String = date.time.toString();

        // Clean up old callback if the name already exists
        if (_requestCallbacks.hasOwnProperty(callbackName)) {
            delete _requestCallbacks[callbackName]
        }

        // Save new callback under this name
        _requestCallbacks[callbackName] = callback;

        return callbackName;
    }

    private function onInvoke(event:InvokeEvent):void
    {
//  NOTE: you can debug onInvoke with these lines of code
//        var debugStr:String;
//        if(event.reason == InvokeEventReason.NOTIFICATION){
//            var obj:Object = event.arguments[0];
//            var arr:Array = [];
//            for (var prop in obj) {
//                arr.push(prop + ": " + obj[prop]);
//            }
//            debugStr = arr.join(", ")
//        }else{
//            debugStr = event.arguments.join(",");
//        }
//
//        log("onInvoke reason: " + event.reason + " params: " + debugStr);

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

    private function onStatus(event:StatusEvent):void
    {
        var dataArr:Array;
        var callbackName:String;
        var callback:Function;

        if (event.code.indexOf("SESSION") != -1) // If the event code contains SESSION, it's an open/reauthorize session result
        {
            var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
            var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
            var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;

            callback = _openSessionCallback;

            _openSessionCallback = null;

            if (callback != null) callback(success, userCancelled, error);
        }
        else if (event.code == "LOGGING") // Simple log message
        {
            // NOTE: logs from native should go only to as3 log
            as3Log(event.level, "NATIVE");
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

                if(callback != null){

                    callback();

                    // TODO we should delete also null values from callback array
                    delete _requestCallbacks[callbackName];
                }
            }
        }
        else // Default case: we check for a registered callback associated with the event code
        {
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
     * Do not use this method outside this class. It may be removed anytime!
     *
     * @param message
     */
    public function log(message:String):void
    {
        if (Facebook.logEnabled) {
            as3Log(message, "AS3");
        }
        if (Facebook.nativeLogEnabled) {
            nativeLog(message);
        }
    }

    private function as3Log(message:String, prefix:String):void
    {
        trace("[AirFacebook][" + prefix + "] " + message);
    }

    private function nativeLog(message:String):void
    {
        if (_context != null) {

            _context.call('nativeLog', message);
        }
    }
}
}
