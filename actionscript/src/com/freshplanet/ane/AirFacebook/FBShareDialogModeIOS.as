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
     * Modes for the FBSDKShareDialog.
     *
     * @see http://developers.facebook.com/docs/reference/ios/current/constants/FBSDKShareDialogMode/
     */
    public class FBShareDialogModeIOS {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * Acts with the most appropriate mode that is available.
         */
        public static const AUTOMATIC:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 0);

        /**
         * Displays the dialog in the main native Facebook app.
         */
        public static const NATIVE:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 1);

        /**
         * Displays the dialog in the iOS integrated share sheet.
         */
        public static const SHARE_SHEET:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 2);

        /**
         * Displays the dialog in Safari.
         */
        public static const BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 3);

        /**
         * Displays the dialog in a UIWebView within the app.
         */
        public static const WEB:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 4);

        /**
         * Displays the feed dialog in Safari.
         */
        public static const FEED_BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 5);

        /**
         * Displays the feed dialog in a UIWebView within the app.
         */
        public static const FEED_WEB:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 6);

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

        private var _value:int = 0; // AUTOMATIC

        /**
         * "private" constructor
         * @param access
         * @param value
         */
        public function FBShareDialogModeIOS(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private{}
