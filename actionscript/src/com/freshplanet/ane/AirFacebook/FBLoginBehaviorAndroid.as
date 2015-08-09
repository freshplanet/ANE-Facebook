package com.freshplanet.ane.AirFacebook {

/**
 * Specifies the behaviors to try during login.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/LoginBehavior/
 */
public class FBLoginBehaviorAndroid {

    /**
     * Specifies that login should attempt login in using the Facebook App, and if that
     * does not work fall back to web dialog auth. This is the default behavior.
     */
    public static const NATIVE_WITH_FALLBACK:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 0);
    /**
     * Specifies that login should only attempt to login using the Facebook App.
     * If the Facebook App cannot be used then the login fails.
     */
    public static const NATIVE_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 1);
    /**
     * Specifies that only the web dialog auth should be used.
     */
    public static const WEB_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 2);

    private var _value:int;

    public function FBLoginBehaviorAndroid(access:Class, value:int)
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
