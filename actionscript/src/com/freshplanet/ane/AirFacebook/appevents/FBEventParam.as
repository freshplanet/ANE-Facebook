/**
 * Created by nodrock on 03/07/15.
 */
package com.freshplanet.ane.AirFacebook.appevents {
public class FBEventParam {

    public static const TYPE_STRING:int = 0;
    public static const TYPE_INT:int = 1;
    public static const TYPE_BOOL:int = 2;

    public static const CONTENT_ID:FBEventParam = new FBEventParam(Private, "fb_content_id", TYPE_STRING);
    public static const CONTENT_TYPE:FBEventParam = new FBEventParam(Private, "fb_content_type", TYPE_STRING);
    public static const CURRENCY:FBEventParam = new FBEventParam(Private, "fb_currency", TYPE_STRING);
    public static const DESCRIPTION:FBEventParam = new FBEventParam(Private, "fb_description", TYPE_STRING);
    public static const LEVEL:FBEventParam = new FBEventParam(Private, "fb_level", TYPE_STRING);
    public static const MAX_RATING_VALUE:FBEventParam = new FBEventParam(Private, "fb_max_rating_value", TYPE_INT);
    public static const NUM_ITEMS:FBEventParam = new FBEventParam(Private, "fb_num_items", TYPE_INT);
    public static const PAYMENT_INFO_AVAILABLE:FBEventParam = new FBEventParam(Private, "fb_payment_info_available", TYPE_BOOL);
    public static const REGISTRATION_METHOD:FBEventParam = new FBEventParam(Private, "fb_registration_method", TYPE_STRING);
    public static const SEARCH_STRING:FBEventParam = new FBEventParam(Private, "fb_search_string", TYPE_STRING);
    public static const SUCCESS:FBEventParam = new FBEventParam(Private, "fb_success", TYPE_BOOL);

    private var _value:String;
    private var _type:int;

    public function FBEventParam(access:Class, value:String, type:int)
    {
        if(access != Private){
            throw new Error("Private constructor call!");
        }

        _value = value;
        _type = type;
    }

    public function get value():String
    {
        return _value;
    }

    public function get type():int
    {
        return _type;
    }
}
}

final class Private{}