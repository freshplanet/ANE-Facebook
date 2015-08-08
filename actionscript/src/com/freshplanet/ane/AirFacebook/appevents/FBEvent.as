package com.freshplanet.ane.AirFacebook.appevents {

/**
 * Event that can be logged by Facebook.
 *
 * @see FBAppEventsConstants
 * @see https://developers.facebook.com/docs/app-events/android
 */
public class FBEvent {

    private static const PARAM_TYPE_STRING:int = 0;
    private static const PARAM_TYPE_INT:int = 1;
    private static const PARAM_TYPE_BOOL:int = 2;

    private var _eventName:String;
    private var _valueToSum:Number;
    private var _paramsKeys:Array;
    private var _paramsTypes:Array;
    private var _paramsValues:Array;

    public function FBEvent()
    {
    }

    public static function createEvent(eventName:String):FBEvent
    {
        if(eventName == null){
            throw new ArgumentError("eventName cannot be null!");
        }
        var event:FBEvent = new FBEvent();
        event._eventName = eventName;
        return event;
    }

    public function get eventName():String
    {
        return _eventName;
    }

    public function get valueToSum():Number
    {
        return _valueToSum;
    }

    public function get paramsKeys():Array
    {
        return _paramsKeys;
    }

    public function get paramsTypes():Array
    {
        return _paramsTypes;
    }

    public function get paramsValues():Array
    {
        return _paramsValues;
    }

    public function getParamValue(eventParam:String):*
    {
        if(_paramsKeys == null){
            return null;
        }
        var index:int = _paramsKeys.indexOf(eventParam);
        if(index != -1){

            return _paramsValues[index];
        } else {

            return null;
        }
    }

    public function setValueToSum(value:Number):FBEvent
    {
        _valueToSum = value;
        return this;
    }

    public function addBoolParam(eventParam:String, value:Boolean):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(_paramsKeys == null){
            _paramsKeys = [];
            _paramsTypes = [];
            _paramsValues = [];
        }
        _paramsKeys.push(eventParam);
        _paramsTypes.push(PARAM_TYPE_BOOL);
        _paramsValues.push(value);
        return this;
    }

    public function addStringParam(eventParam:String, value:String):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(_paramsKeys == null){
            _paramsKeys = [];
            _paramsTypes = [];
            _paramsValues = [];
        }
        _paramsKeys.push(eventParam);
        _paramsTypes.push(PARAM_TYPE_STRING);
        _paramsValues.push(value);
        return this;
    }

    public function addIntParam(eventParam:String, value:int):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(_paramsKeys == null){
            _paramsKeys = [];
            _paramsTypes = [];
            _paramsValues = [];
        }
        _paramsKeys.push(eventParam);
        _paramsTypes.push(PARAM_TYPE_INT);
        _paramsValues.push(value);
        return this;
    }

    public static function create_ACHIEVED_LEVEL(level:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_ACHIEVED_LEVEL)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_LEVEL, level);
    }

    public static function create_ACTIVATED_APP():FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_ACTIVATED_APP);
    }

    public static function create_ADDED_PAYMENT_INFO(success:Boolean):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_ADDED_PAYMENT_INFO)
                .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success);
    }

    public static function create_ADDED_TO_CART(price:Number, contentType:String, contentId:String, currency:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_ADDED_TO_CART)
                .setValueToSum(price)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
    }

    public static function create_ADDED_TO_WISHLIST(price:Number, contentType:String, contentId:String, currency:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_ADDED_TO_WISHLIST)
                .setValueToSum(price)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
    }

    public static function create_COMPLETED_REGISTRATION(registrationMethod:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_LEVEL, registrationMethod);
    }

    public static function create_COMPLETED_TUTORIAL(success:Boolean, contentId:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_COMPLETED_TUTORIAL)
                .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId);
    }
    public static function create_INITIATED_CHECKOUT(totalPrice:Number, contentType:String, contentId:String, numItems:int, paymentInfoAvailable:Boolean, currency:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_INITIATED_CHECKOUT)
                .setValueToSum(totalPrice)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency)
                .addIntParam(FBAppEventsConstants.EVENT_PARAM_NUM_ITEMS, numItems)
                .addBoolParam(FBAppEventsConstants.EVENT_PARAM_PAYMENT_INFO_AVAILABLE, paymentInfoAvailable);
    }
    public static function create_PURCHASED(price:Number, contentType:String, contentId:String, numItems:int, currency:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_PURCHASED)
                .setValueToSum(price)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency)
                .addIntParam(FBAppEventsConstants.EVENT_PARAM_NUM_ITEMS, numItems);
    }
    public static function create_RATED(rating:Number, contentType:String, contentId:String, maxRatingValue:int):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_RATED)
                .setValueToSum(rating)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addIntParam(FBAppEventsConstants.EVENT_PARAM_MAX_RATING_VALUE, maxRatingValue);
    }
    public static function create_SEARCHED(contentType:String, searchString:String, success:Boolean):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_SEARCHED)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_SEARCH_STRING, searchString)
                .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success);
    }
    public static function create_SPENT_CREDITS(creditsCount:Number, contentType:String, contentId:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_SPENT_CREDITS)
                .setValueToSum(creditsCount)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId);
    }
    public static function create_UNLOCKED_ACHIEVEMENT(description:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_UNLOCKED_ACHIEVEMENT)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_DESCRIPTION, description);
    }
    public static function create_VIEWED_CONTENT(price:Number, contentType:String, contentId:String, currency:String):FBEvent
    {
        return FBEvent.createEvent(FBAppEventsConstants.EVENT_NAME_VIEWED_CONTENT)
                .setValueToSum(price)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
    }
}
}
