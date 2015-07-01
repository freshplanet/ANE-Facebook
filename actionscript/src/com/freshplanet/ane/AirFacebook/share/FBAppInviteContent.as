package com.freshplanet.ane.AirFacebook.share {

/**
 * Describes the content that will be displayed by the AppInviteDialog.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/AppInviteContent/
 */
public class FBAppInviteContent {

    /**
     * App Link for what should be opened when the recipient clicks on the install/play button on the app invite page.
     * @required
     */
    public var appLinkUrl:String;
    /**
     * A url to an image to be used in the invite.
     */
    public var previewImageUrl:String;

    public function FBAppInviteContent() {}

    public function toString():String
    {
        var str:String = "[FBAppInviteContent";

        str += " appLinkUrl:'" + appLinkUrl + "'";
        str += " previewImageUrl:'" + previewImageUrl + "'";

        return str + "]";
    }
}
}
