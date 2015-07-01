package com.freshplanet.ane.AirFacebook {

/**
 * Specifies the behaviors to try during login.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/LoginBehavior/
 */
public class FBLoginBehaviorAndroid {

    /**
     * Specifies that login should attempt Single Sign On (SSO), and if that does not work fall back to dialog auth. This is the default behavior.
     */
    public static const SSO_WITH_FALLBACK:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 0);
    /**
     * Specifies that login should only attempt SSO. If SSO fails, then the login fails.
     */
    public static const SSO_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 1);
    /**
     * Specifies that SSO should not be attempted, and to only use dialog auth.
     */
    public static const SUPPRESS_SSO:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 2);

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
