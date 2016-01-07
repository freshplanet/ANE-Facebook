package com.freshplanet.ane.AirFacebook
{
/**
 * This class represents a basic Facebook profile.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/Profile/
 */
public class FBProfile{

    /**
     * The first name of the profile. Can be null.
     */
    public var firstName:String;
    /**
     * The last name of the profile. Can be null.
     */
    public var lastName:String;
    /**
     * The link for this profile. Can be null.
     */
    public var linkUrl:String;
    /**
     * The middle name of the profile. Can be null.
     */
    public var middleName:String;
    /**
     * The name of the profile. Can be null.
     */
    public var name:String;
    /**
     * The last time the profile data was fetched.
     * (NOTE: IOS only)
     */
    public var refreshDate:Number;
    /**
     * The id of the profile.
     */
    public var userID:String;

    public function FBProfile(){}

    public function toString():String
    {
        var str:String = "[FBAccessToken";

        str += " firstName:'" + firstName + "'";
        str += " lastName:'" + lastName + "'";
        str += " linkUrl:'" + linkUrl + "'";
        str += " middleName:'" + middleName + "'";
        str += " name:'" + name + "'";
        str += " refreshDate:'" + refreshDate + "'";
        str += " userID:'" + userID + "'";

        return str + "]";
    }
}
}