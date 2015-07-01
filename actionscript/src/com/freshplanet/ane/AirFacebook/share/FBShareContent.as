package com.freshplanet.ane.AirFacebook.share {

/**
 * Provides the base class for content to be shared. Contains all common methods for the different types of content.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/ShareContent/
 */
public class FBShareContent {

    /**
     * URL for the content being shared. This URL will be checked for app link meta tags for linking in platform specific ways.
     */
    public var contentUrl:String;
    /**
     * List of Ids for taggable people to tag with this content.
     */
    public var peopleIds:Array;
    /**
     * The Id for a place to tag with this content.
     */
    public var placeId:String;
    /**
     * A value to be added to the referrer URL when a person follows a link from this shared content on feed.
     */
    public var ref:String;

    public function FBShareContent() {}

    public function toString():String
    {
        var str:String = "[FBShareContent";

        str += " contentUrl:'" + contentUrl + "'";
        str += " peopleIds:'" + peopleIds + "'";
        str += " placeId:'" + placeId + "'";
        str += " ref:'" + ref + "'";

        return str + "]";
    }
}
}
