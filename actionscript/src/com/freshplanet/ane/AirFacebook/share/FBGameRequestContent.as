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
package com.freshplanet.ane.AirFacebook.share {

    public class FBGameRequestContent {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        public var title:String = null;
        public var data:String = null;
        public var message:String = null;
        public var objectID:String = null;
        public var recipientSuggestions:Array = null;

        /**
         * users the dialog will be targeted at (will only use the 1st user on Android)
         */
        public var recipients:Array = null;

        /**
         *
         */
        public function get actionType():uint {
            return _actionType;
        }

        /**
         *
         */
        public function get filters():uint {
            return _filters;
        }

        /**
         *
         * @param val
         */
        public function setActionType(val:FBGameRequestActionType):void {
            _actionType = val.value;
        }

        /**
         *
         * @param val
         */
        public function setFilter(val:FBGameRequestFilter):void {
            _filters = val.value;
        }

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									 	PRIVATE API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        private var _actionType:uint = 0; // NONE
        private var _filters:uint = 0; // NONE
    }
}
