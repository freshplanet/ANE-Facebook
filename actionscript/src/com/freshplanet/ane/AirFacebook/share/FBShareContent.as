/**
 * Created by nodrock on 30/06/15.
 */
package com.freshplanet.ane.AirFacebook.share {
public class FBShareContent {

    public var contentUrl:String;
    public var peopleIds:Array;
    public var placeId:String;
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
