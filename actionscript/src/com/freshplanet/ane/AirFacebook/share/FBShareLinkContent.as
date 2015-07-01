package com.freshplanet.ane.AirFacebook.share {

/**
 * Describes link content to be shared.
 *
 * @see FBShareContent
 * @see http://developers.facebook.com/docs/reference/android/current/class/ShareLinkContent/
 */
public class FBShareLinkContent extends FBShareContent{

    /**
     * The description of the link. If not specified, this field is automatically populated by information scraped from the link, typically the title of the page.
     */
    public var contentDescription:String;
    /**
     * The title to display for this link.
     */
    public var contentTitle:String;
    /**
     * The URL of a picture to attach to this content.
     */
    public var imageUrl:String;

    public function FBShareLinkContent() {}

    override public function toString():String
    {
        var str:String = "[FBShareLinkContent";

        str += " contentDescription:'" + contentDescription + "'";
        str += " contentTitle:'" + contentTitle + "'";
        str += " imageUrl:'" + imageUrl + "'";
        str += " " + super.toString();

        return str + "]";
    }
}
}
