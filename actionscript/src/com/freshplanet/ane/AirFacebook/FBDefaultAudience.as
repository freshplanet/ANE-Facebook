/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBDefaultAudience {

    public static const FRIENDS:FBDefaultAudience = new FBDefaultAudience(Private, 0);
    public static const ONLY_ME:FBDefaultAudience = new FBDefaultAudience(Private, 1);
    public static const EVERYONE:FBDefaultAudience = new FBDefaultAudience(Private, 2);

    private var _value:int;

    public function FBDefaultAudience(access:Class, value:int)
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
