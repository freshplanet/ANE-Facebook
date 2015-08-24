package com.freshplanet.ane.AirFacebook {

/**
 * Certain operations such as publishing a status or publishing a photo require an audience.
 * When the user grants an application permission to perform a publish operation, a default
 * audience is selected as the publication ceiling for the application. This enumerated value
 * allows the application to select which audience to ask the user to grant publish permission for.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/DefaultAudience/
 */
public class FBDefaultAudience {

    /**
     * Indicates that the user's friends are able to see posts made by the application.
     */
    public static const FRIENDS:FBDefaultAudience = new FBDefaultAudience(Private, 0);
    /**
     * Indicates only the user is able to see posts made by the application.
     */
    public static const ONLY_ME:FBDefaultAudience = new FBDefaultAudience(Private, 1);
    /**
     * Indicates that all Facebook users are able to see posts made by the application.
     */
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
