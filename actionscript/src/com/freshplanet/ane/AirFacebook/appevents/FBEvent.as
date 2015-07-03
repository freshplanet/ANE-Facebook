/**
 * Created by nodrock on 03/07/15.
 */
package com.freshplanet.ane.AirFacebook.appevents {
public class FBEvent {

    private var _eventName:FBEventName;
    private var _valueToSum:Number;
    private var _params:Array;
    private var _paramsValue:Array;

    public function FBEvent()
    {
    }

    public static function createEvent(eventName:FBEventName):FBEvent
    {
        if(eventName == null){
            throw new ArgumentError("eventName cannot be null!");
        }
        var event:FBEvent = new FBEvent();
        event._eventName = eventName;
        return event;
    }

    public function get eventName():FBEventName
    {
        return _eventName;
    }

    public function get eventNameValue():String
    {
        return _eventName.value;
    }

    public function get valueToSum():Number
    {
        return _valueToSum;
    }

    public function get params():Array
    {
        return _params;
    }

    public function getParamValue(eventParam:FBEventParam):*
    {
        if(_params == null){
            return null;
        }
        var index:int = _params.indexOf(eventParam);
        if(index != -1){

            return _paramsValue[index];
        } else {

            return null;
        }
    }

    public function setValue(value:Number):FBEvent
    {
        _valueToSum = value;
        return this;
    }

    public function addBoolParam(eventParam:FBEventParam, value:Boolean):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(eventParam.type != FBEventParam.TYPE_BOOL){
            throw new ArgumentError(eventParam.value + " has different type!");
        }
        if(_params == null){
            _params = [];
            _paramsValue = [];
        }
        _params.push(eventParam);
        _paramsValue.push(value);
        return this;
    }

    public function addStringParam(eventParam:FBEventParam, value:String):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(eventParam.type != FBEventParam.TYPE_STRING){
            throw new ArgumentError(eventParam.value + " has different type!");
        }
        if(_params == null){
            _params = [];
            _paramsValue = [];
        }
        _params.push(eventParam);
        _paramsValue.push(value);
        return this;
    }

    public function addIntParam(eventParam:FBEventParam, value:int):FBEvent
    {
        if(eventParam == null){
            throw new ArgumentError("eventParam cannot be null!");
        }
        if(eventParam.type != FBEventParam.TYPE_INT){
            throw new ArgumentError(eventParam.value + " has different type!");
        }
        if(_params == null){
            _params = [];
            _paramsValue = [];
        }
        _params.push(eventParam);
        _paramsValue.push(value);
        return this;
    }
}
}
