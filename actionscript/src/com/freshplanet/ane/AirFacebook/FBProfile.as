package com.freshplanet.ane.AirFacebook
{
    public class FBProfile{

        public var firstName:String;
        public var lastName:String;
        public var linkUrl:String;
        public var middleName:String;
        public var name:String;
        public var refreshDate:Number;
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