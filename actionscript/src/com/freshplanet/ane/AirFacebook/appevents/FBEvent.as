/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.freshplanet.ane.AirFacebook.appevents {

    /**
     * Event that can be logged by Facebook.
     *
     * @see FBAppEventsConstants
     * @see https://developers.facebook.com/docs/app-events/android
     */
    public class FBEvent {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * Creates custom event with name eventName.
         *
         * @param eventName
         * @return created event
         */
        public static function create(eventName:String):FBEvent {

            _checkNameRules(eventName);

            var event:FBEvent = new FBEvent(Private);
            event._eventName = eventName;

            return event;
        }

        /**
         * Sets valueToSum.
         * @param value
         * @return updated event
         */
        public function setValueToSum(value:Number):FBEvent {

            _valueToSum = value;
            return this;
        }

        /**
         * Adds bool parameter with name eventParam.
         *
         * @param eventParam
         * @param value
         * @return updated event
         */
        public function addBoolParam(eventParam:String, value:Boolean):FBEvent {

            _checkAddParam(eventParam);

            _paramsKeys.push(eventParam);
            _paramsTypes.push(PARAM_TYPE_BOOL);
            _paramsValues.push(value);

            return this;
        }

        /**
         * Adds string parameter with name eventParam.
         *
         * @param eventParam
         * @param value
         * @return updated event
         */
        public function addStringParam(eventParam:String, value:String):FBEvent {

            _checkAddParam(eventParam, value);

            _paramsKeys.push(eventParam);
            _paramsTypes.push(PARAM_TYPE_STRING);
            _paramsValues.push(value);

            return this;
        }

        /**
         * Adds int parameter with name eventParam.
         *
         * @param eventParam
         * @param value
         * @return updated event
         */
        public function addIntParam(eventParam:String, value:int):FBEvent {

            _checkAddParam(eventParam);

            _paramsKeys.push(eventParam);
            _paramsTypes.push(PARAM_TYPE_INT);
            _paramsValues.push(value);

            return this;
        }

        //----------------------------------
        // Internal getters
        //----------------------------------

        public function get eventName():String {
            return _eventName;
        }

        public function get valueToSum():Number {
            return _valueToSum;
        }

        public function get paramsKeys():Array {
            return _paramsKeys;
        }

        public function get paramsTypes():Array {
            return _paramsTypes;
        }

        public function get paramsValues():Array {
            return _paramsValues;
        }

        //----------------------------------
        // Static constructors
        //----------------------------------

        /**
         *
         * @param level
         * @return
         */
        public static function create_ACHIEVED_LEVEL(level:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_ACHIEVED_LEVEL)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_LEVEL, level);
        }

        /**
         *
         * @return
         */
        public static function create_ACTIVATED_APP():FBEvent {
            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_ACTIVATED_APP);
        }

        /**
         *
         * @param success
         * @return
         */
        public static function create_ADDED_PAYMENT_INFO(success:Boolean):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_ADDED_PAYMENT_INFO)
                    .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success);
        }

        /**
         *
         * @param price
         * @param contentType
         * @param contentId
         * @param currency
         * @return
         */
        public static function create_ADDED_TO_CART(price:Number,
                                                    contentType:String,
                                                    contentId:String,
                                                    currency:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_ADDED_TO_CART)
                    .setValueToSum(price)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
        }

        /**
         *
         * @param price
         * @param contentType
         * @param contentId
         * @param currency
         * @return
         */
        public static function create_ADDED_TO_WISHLIST(price:Number,
                                                        contentType:String,
                                                        contentId:String,
                                                        currency:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_ADDED_TO_WISHLIST)
                    .setValueToSum(price)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
        }

        /**
         *
         * @param registrationMethod
         * @return
         */
        public static function create_COMPLETED_REGISTRATION(registrationMethod:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_LEVEL, registrationMethod);
        }

        /**
         *
         * @param success
         * @param contentId
         * @return
         */
        public static function create_COMPLETED_TUTORIAL(success:Boolean,
                                                         contentId:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_COMPLETED_TUTORIAL)
                    .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId);
        }

        /**
         *
         * @param totalPrice
         * @param contentType
         * @param contentId
         * @param numItems
         * @param paymentInfoAvailable
         * @param currency
         * @return
         */
        public static function create_INITIATED_CHECKOUT(totalPrice:Number,
                                                         contentType:String,
                                                         contentId:String,
                                                         numItems:int,
                                                         paymentInfoAvailable:Boolean,
                                                         currency:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_INITIATED_CHECKOUT)
                    .setValueToSum(totalPrice)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency)
                    .addIntParam(FBAppEventsConstants.EVENT_PARAM_NUM_ITEMS, numItems)
                    .addBoolParam(FBAppEventsConstants.EVENT_PARAM_PAYMENT_INFO_AVAILABLE, paymentInfoAvailable);
        }

        /**
         *
         * @param price
         * @param contentType
         * @param contentId
         * @param numItems
         * @param currency
         * @return
         */
        public static function create_PURCHASED(price:Number,
                                                contentType:String,
                                                contentId:String,
                                                numItems:int,
                                                currency:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_PURCHASED)
                    .setValueToSum(price)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency)
                    .addIntParam(FBAppEventsConstants.EVENT_PARAM_NUM_ITEMS, numItems);
        }

        /**
         *
         * @param rating
         * @param contentType
         * @param contentId
         * @param maxRatingValue
         * @return
         */
        public static function create_RATED(rating:Number,
                                            contentType:String,
                                            contentId:String,
                                            maxRatingValue:int):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_RATED)
                    .setValueToSum(rating)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addIntParam(FBAppEventsConstants.EVENT_PARAM_MAX_RATING_VALUE, maxRatingValue);
        }

        /**
         *
         * @param contentType
         * @param searchString
         * @param success
         * @return
         */
        public static function create_SEARCHED(contentType:String,
                                               searchString:String,
                                               success:Boolean):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_SEARCHED)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_SEARCH_STRING, searchString)
                    .addBoolParam(FBAppEventsConstants.EVENT_PARAM_SUCCESS, success);
        }

        /**
         *
         * @param creditsCount
         * @param contentType
         * @param contentId
         * @return
         */
        public static function create_SPENT_CREDITS(creditsCount:Number,
                                                    contentType:String,
                                                    contentId:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_SPENT_CREDITS)
                    .setValueToSum(creditsCount)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId);
        }

        /**
         *
         * @param description
         * @return
         */
        public static function create_UNLOCKED_ACHIEVEMENT(description:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_UNLOCKED_ACHIEVEMENT)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_DESCRIPTION, description);
        }

        /**
         *
         * @param price
         * @param contentType
         * @param contentId
         * @param currency
         * @return
         */
        public static function create_VIEWED_CONTENT(price:Number,
                                                     contentType:String,
                                                     contentId:String,
                                                     currency:String):FBEvent {

            return FBEvent.create(FBAppEventsConstants.EVENT_NAME_VIEWED_CONTENT)
                    .setValueToSum(price)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
                    .addStringParam(FBAppEventsConstants.EVENT_PARAM_CURRENCY, currency);
        }

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									 	PRIVATE API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        private static const PARAM_TYPE_STRING:int = 0;
        private static const PARAM_TYPE_INT:int = 1;
        private static const PARAM_TYPE_BOOL:int = 2;

        private var _eventName:String = null;
        private var _valueToSum:Number = 0;
        private var _paramsKeys:Array = null;
        private var _paramsTypes:Array = null;
        private var _paramsValues:Array = null;

        /**
         * "private" constructor
         */
        public function FBEvent(access:Class) {

            if (access != Private)
                throw new Error("Private constructor call! Please use FBEvent.create(...) instead or other predefined static constructors!");
        }

        /**
         *
         * @param name
         */
        private static function _checkNameRules(name:String):void {

            if (name == null)
                throw new ArgumentError("Event name or parameter name cannot be null!");

            if (name.length < 2 || name.length > 40)
                throw new ArgumentError("Event name or parameter name is too short or too long. Length must be between 2 and 40 characters!");

            if (!name.match(/[ a-zA-Z0-9_-]*/))
                throw new ArgumentError("Event name or parameter name must consist of alphanumeric characters, _, -, or spaces!");
        }

        /**
         *
         * @param eventParam
         * @param value
         */
        private function _checkAddParam(eventParam:String, value:String = null):void {

            _checkNameRules(eventParam);

            if (value != null && value.length > 100)
                throw new ArgumentError("Value cannot exceed 100 characters!");

            if (_paramsKeys == null) {

                _paramsKeys = [];
                _paramsTypes = [];
                _paramsValues = [];
            }

            if (_paramsKeys.length == 25)
                throw new ArgumentError("Maximum number of parameters reached!")
        }
    }
}

class Private {}