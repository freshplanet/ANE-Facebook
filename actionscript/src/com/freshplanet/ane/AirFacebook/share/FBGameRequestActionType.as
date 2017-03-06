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

    /**
     *
     */
    public class FBGameRequestActionType {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        public static const NONE:FBGameRequestActionType = new FBGameRequestActionType(Private, 0);
        public static const SEND:FBGameRequestActionType = new FBGameRequestActionType(Private, 1);
        public static const ASK_FOR:FBGameRequestActionType = new FBGameRequestActionType(Private, 2);
        public static const TURN:FBGameRequestActionType = new FBGameRequestActionType(Private, 3);

        /**
         *
         */
        public function get value():int {
            return _value;
        }

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									 	PRIVATE API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        private var _value:int = 0; // NONE

        /**
         * "private" constructor
         * @param access
         * @param value
         */
        public function FBGameRequestActionType(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private {}