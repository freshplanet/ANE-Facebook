package com.freshplanet.ane.AirFacebook
{
    public class FBAccessToken{

        public var appID:String;
        public var declinedPermissions:Array;
        public var expirationDate:Number;
        public var permissions:Array;
        public var refreshDate:Number;
        public var tokenString:String;
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