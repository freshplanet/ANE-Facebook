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
package com.freshplanet.ane.AirFacebook {

    /**
     * Specifies the behaviors to try during login.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/LoginBehavior/
     */
    public class FBLoginBehaviorAndroid {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * Specifies that login should attempt login in using the Facebook App, and if that
         * does not work fall back to web dialog auth. This is the default behavior.
         */
        public static const NATIVE_WITH_FALLBACK:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 0);

        /**
         * Specifies that login should only attempt to login using the Facebook App.
         * If the Facebook App cannot be used then the login fails.
         */
        public static const NATIVE_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 1);

        /**
         * Specifies that only the web dialog auth should be used.
         */
        public static const WEB_ONLY:FBLoginBehaviorAndroid = new FBLoginBehaviorAndroid(Private, 2);

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

        private var _value:int = 0; // NATIVE_WITH_FALLBACK

        /**
         * "private" constructor
         * @param access
         * @param value
         */
        public function FBLoginBehaviorAndroid(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private {}
