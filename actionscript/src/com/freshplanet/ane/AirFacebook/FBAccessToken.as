package com.freshplanet.ane.AirFacebook
{

/**
 * This class represents an immutable access token for using Facebook APIs.
 * It also includes associated metadata such as expiration date and permissions.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/AccessToken/
 */
public class FBAccessToken{

    /**
     * The ID of the Facebook Application associated with this access token
     */
    public var appID:String;
    /**
     * The permissions that were declined when the token was obtained; may be null if permission set is unknown
     */
    public var declinedPermissions:Array;
    /**
     * The expiration date associated with the token; if null, an infinite expiration time is assumed (but will become correct when the token is refreshed)
     */
    public var expirationDate:Number;
    /**
     * The permissions that were requested when the token was obtained (or when it was last reauthorized); may be null if permission set is unknown
     */
    public var permissions:Array;
    /**
     * The last time the token was refreshed (or when it was first obtained); if null, the current time is used.
     */
    public var refreshDate:Number;
    /**
     * The access token string obtained from Facebook
     */
    public var tokenString:String;
    /**
     * The id of the user
     */
    public var userID:String;

    public function FBAccessToken(){}

    public function toString():String
    {
        var str:String = "[FBAccessToken";

        str += " appID:'" + appID + "'";
        str += " declinedPermissions:'" + (declinedPermissions ? declinedPermissions.join(",") : "null") + "'";
        str += " expirationDate:'" + expirationDate + "'";
        str += " permissions:'" + (permissions ? permissions.join(",") : "null") + "'";
        str += " refreshDate:'" + refreshDate + "'";
        str += " tokenString:'" + tokenString + "'";
        str += " userID:'" + userID + "'";

        return str + "]";
    }
}
}