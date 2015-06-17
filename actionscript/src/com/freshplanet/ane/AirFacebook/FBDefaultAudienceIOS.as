/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBDefaultAudienceIOS {

    public static const FRIENDS:FBDefaultAudienceIOS = new FBDefaultAudienceIOS(Private, 0);
    public static const ONLY_ME:FBDefaultAudienceIOS = new FBDefaultAudienceIOS(Private, 1);
    public static const EVERYONE:FBDefaultAudienceIOS = new FBDefaultAudienceIOS(Private, 2);

    private var _value:int;

    public function FBDefaultAudienceIOS(access:Class, value:int)
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
