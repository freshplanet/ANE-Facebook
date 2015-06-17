/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBLoginBehaviorIOS {

    public static const NATIVE:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 0);
    public static const BROWSER:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 1);
    public static const SYSTEM_ACCOUNT:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 2);
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
