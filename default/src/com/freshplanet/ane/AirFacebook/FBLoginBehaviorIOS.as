package com.freshplanet.ane.AirFacebook {

/**
 * Passed to the FBSDKLoginManager to indicate how Facebook Login should be attempted.
 *
 * @see http://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/
 */
public class FBLoginBehaviorIOS {

    /**
     * Attempts log in through the native Facebook app. If the Facebook app is
     * not installed on the device, falls back to FBSDKLoginBehaviorBrowser. This is the
     * default behavior.
     */
    public static const NATIVE:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 0);
    /**
     * Attempts log in through the Safari browser.
     */
    public static const BROWSER:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 1);
    /**
     * Attempts log in through the Facebook account currently signed in through Settings.
     * If no Facebook account is signed in, falls back to FBSDKLoginBehaviorNative.
     */
    public static const SYSTEM_ACCOUNT:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 2);
    /**
     * Attempts log in through a modal UIWebView pop up.
     */
    public static const WEB:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 3);

    private var _value:int;

    public function FBLoginBehaviorIOS(access:Class, value:int)
    {
        if(access != Private){
            throw new Error("Private constructor call!");
        }

        _value = value;
    }

    public function get value():int
    {
        return _value;
    }
}
}

final class Private{}
