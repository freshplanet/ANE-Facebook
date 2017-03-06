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
     * Passed to the FBSDKLoginManager to indicate how Facebook Login should be attempted.
     *
     * @see http://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/
     */
    public class FBLoginBehaviorIOS {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * Attempts log in through the native Facebook app. If the Facebook app is
         * not installed on the device, falls back to FBSDKLoginBehaviorBrowser. This is the
         * default behavior.
         */
        public static const NATIVE:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 0);

        /**
         * Attempts log in through the Safari browser.
         */
        public static const BROWSER:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 1);

        /**
         * Attempts log in through the Facebook account currently signed in through Settings.
         * If no Facebook account is signed in, falls back to FBSDKLoginBehaviorNative.
         */
        public static const SYSTEM_ACCOUNT:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 2);

        /**
         * Attempts log in through a modal UIWebView pop up.
         */
        public static const WEB:FBLoginBehaviorIOS = new FBLoginBehaviorIOS(Private, 3);

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

        private var _value:int = 0; // NATIVE

        /**
         * "private" constructor
         * @param access
         * @param value
         */
        public function FBLoginBehaviorIOS(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private {}
