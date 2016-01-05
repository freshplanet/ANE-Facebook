package com.freshplanet.ane.AirFacebook.appevents {

/**
 * Predefined event and parameter names for logging events common to many apps.
 *
 * @see FBEvent
 * @see https://developers.facebook.com/docs/app-events/android
 */
public class FBAppEventsConstants {
    public function FBAppEventsConstants()
    {
    }

    /** Log this event when the user has achieved a level in the app. */
    public static const EVENT_NAME_ACHIEVED_LEVEL:String = "fb_mobile_level_achieved";
    /** Log this event when an app is being activated. */
    public static const EVENT_NAME_ACTIVATED_APP:String = "fb_mobile_activate_app";
    /** Log this event when the user has entered their payment info. */
    public static const EVENT_NAME_ADDED_PAYMENT_INFO:String = "fb_mobile_add_payment_info";
    /**
     * Log this event when the user has added an item to their cart.
     * The valueToSum passed to logEvent should be the item's price.
     */
    public static const EVENT_NAME_ADDED_TO_CART:String = "fb_mobile_add_to_cart";
    /**
     * Log this event when the user has added an item to their wishlist.
     * The valueToSum passed to logEvent should be the item's price.
     */
    public static const EVENT_NAME_ADDED_TO_WISHLIST:String = "fb_mobile_add_to_wishlist";
    /** Log this event when the user has completed registration with the app. */
    public static const EVENT_NAME_COMPLETED_REGISTRATION:String = "fb_mobile_complete_registration";
    /** Log this event when the user has completed a tutorial in the app. */
    public static const EVENT_NAME_COMPLETED_TUTORIAL:String = "fb_mobile_tutorial_completion";
    /**
     * Log this event when the user has entered the checkout process.
     * The valueToSum passed to logEvent should be the total price in the cart.
     */
    public static const EVENT_NAME_INITIATED_CHECKOUT:String = "fb_mobile_initiated_checkout";
    /**
     * Log this event when the user has completed a purchase. The {@link
            * AppEventsLogger#logPurchase(java.math.BigDecimal, java.util.Currency)} method is a shortcut
     * for logging this event.
     */
    public static const EVENT_NAME_PURCHASED:String = "fb_mobile_purchase";
    /**
     * Log this event when the user has rated an item in the app.
     * The valueToSum passed to logEvent should be the numeric rating.
     */
    public static const EVENT_NAME_RATED:String = "fb_mobile_rate";
    /** Log this event when the user has performed a search within the app. */
    public static const EVENT_NAME_SEARCHED:String = "fb_mobile_search";
    /**
     * Log this event when the user has spent app credits.
     * The valueToSum passed to logEvent should be the number of credits spent.
     */
    public static const EVENT_NAME_SPENT_CREDITS:String = "fb_mobile_spent_credits";
    /** Log this event when the user has unlocked an achievement in the app. */
    public static const EVENT_NAME_UNLOCKED_ACHIEVEMENT:String = "fb_mobile_achievement_unlocked";
    /** Log this event when the user has viewed a form of content in the app. */
    public static const EVENT_NAME_VIEWED_CONTENT:String = "fb_mobile_content_view";


    /**
     * Parameter key used to specify an ID for the specific piece of content being logged about.
     * This could be an EAN, article identifier, etc., depending on the nature of the app.
     */
    public static const EVENT_PARAM_CONTENT_ID:String = "fb_content_id";
    /**
     * Parameter key used to specify a generic content type/family for the logged event, e.g.
     * "music", "photo", "video".  Options to use will vary depending on the nature of the app.
     */
    public static const EVENT_PARAM_CONTENT_TYPE:String = "fb_content_type";
    /**
     * Parameter key used to specify currency used with logged event.  E.g. "USD", "EUR", "GBP". See
     * <a href="http://en.wikipedia.org/wiki/ISO_4217">ISO-4217</a>
     * for specific values.
     */
    public static const EVENT_PARAM_CURRENCY:String = "fb_currency";
    /**
     * Parameter key used to specify a description appropriate to the event being logged.
     * E.g., the name of the achievement unlocked in the EVENT_NAME_ACHIEVEMENT_UNLOCKED event.
     */
    public static const EVENT_PARAM_DESCRIPTION:String = "fb_description";
    /** Parameter key used to specify the level achieved in an EVENT_NAME_LEVEL_ACHIEVED event. */
    public static const EVENT_PARAM_LEVEL:String = "fb_level";
    /**
     * Parameter key used to specify the maximum rating available for the EVENT_NAME_RATE event.
     * E.g., "5" or "10".
     */
    public static const EVENT_PARAM_MAX_RATING_VALUE:String = "fb_max_rating_value";
    /**
     * Parameter key used to specify how many items are being processed for an
     * EVENT_NAME_INITIATED_CHECKOUT or EVENT_NAME_PURCHASE event.
     */
    public static const EVENT_PARAM_NUM_ITEMS:String = "fb_num_items";
    /**
     * Parameter key used to specify whether payment info is available for the
     * EVENT_NAME_INITIATED_CHECKOUT event. EVENT_PARAM_VALUE_YES and EVENT_PARAM_VALUE_NO are good
     * canonical values to use for this parameter.
     */
    public static const EVENT_PARAM_PAYMENT_INFO_AVAILABLE:String = "fb_payment_info_available";
    /**
     * Parameter key used to specify the method the user has used to register for the app, e.g.,
     * "Facebook", "email", "Twitter", etc.
     */
    public static const EVENT_PARAM_REGISTRATION_METHOD:String = "fb_registration_method";
    /** Parameter key used to specify the string provided by the user for a search operation. */
    public static const EVENT_PARAM_SEARCH_STRING:String = "fb_search_string";
    /**
     * Parameter key used to specify whether the activity being logged about was successful or not.
     * EVENT_PARAM_VALUE_YES and EVENT_PARAM_VALUE_NO are good canonical values to use for this
     * parameter.
     */
    public static const EVENT_PARAM_SUCCESS:String = "fb_success";
}
}
