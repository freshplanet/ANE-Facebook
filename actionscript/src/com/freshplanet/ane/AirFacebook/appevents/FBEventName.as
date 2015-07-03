/**
 * Created by nodrock on 03/07/15.
 */
package com.freshplanet.ane.AirFacebook.appevents {
public class FBEventName {

    public static const ACHIEVED_LEVEL:FBEventName = new FBEventName(Private, "fb_mobile_level_achieved");
    public static const ACTIVATED_APP:FBEventName = new FBEventName(Private, "fb_mobile_activate_app");
    public static const ADDED_PAYMENT_INFO:FBEventName = new FBEventName(Private, "fb_mobile_add_payment_info");
    public static const ADDED_TO_CART:FBEventName = new FBEventName(Private, "fb_mobile_add_to_cart");
    public static const ADDED_TO_WISHLIST:FBEventName = new FBEventName(Private, "fb_mobile_add_to_wishlist");
    public static const COMPLETED_REGISTRATION:FBEventName = new FBEventName(Private, "fb_mobile_complete_registration");
    public static const COMPLETED_TUTORIAL:FBEventName = new FBEventName(Private, "fb_mobile_tutorial_completion");
    public static const INITIATED_CHECKOUT:FBEventName = new FBEventName(Private, "fb_mobile_initiated_checkout");
    public static const PURCHASED:FBEventName = new FBEventName(Private, "fb_mobile_purchase");
    public static const RATED:FBEventName = new FBEventName(Private, "fb_mobile_rate");
    public static const SEARCHED:FBEventName = new FBEventName(Private, "fb_mobile_search");
    public static const SPENT_CREDITS:FBEventName = new FBEventName(Private, "fb_mobile_spent_credits");
    public static const UNLOCKED_ACHIEVEMENT:FBEventName = new FBEventName(Private, "fb_mobile_achievement_unlocked");
    public static const VIEWED_CONTENT:FBEventName = new FBEventName(Private, "fb_mobile_content_view");

    private var _value:String;

    public function FBEventName(access:Class, value:String)
    {
        if(access != Private){
            throw new Error("Private constructor call!");
        }

        _value = value;
    }

    public function get value():String
    {
        return _value;
    }
}
}

final class Private{}