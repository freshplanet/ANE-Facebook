/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBLoginBehaviorAndroid {

    public static const SSO_WITH_FALLBACK:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 0);
    public static const SSO_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 1);
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
