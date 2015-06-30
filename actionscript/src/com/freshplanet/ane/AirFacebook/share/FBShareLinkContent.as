/**
 * Created by nodrock on 30/06/15.
 */
package com.freshplanet.ane.AirFacebook.share {
public class FBShareLinkContent extends FBShareContent{

    public var contentDescription:String;
    public var contentTitle:String;
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
