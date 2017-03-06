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
     * The mode for the share dialog.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/ShareDialog.Mode/
     */
    public class FBShareDialogModeAndroid {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * The mode is determined automatically.
         */
        public static const AUTOMATIC:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 0);

        /**
         * The native dialog is used.
         */
        public static const NATIVE:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 1);

        /**
         * The web dialog is used.
         */
        public static const WEB:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 2);

        /**
         * The feed dialog is used.
         */
        public static const FEED:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 3);

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
        public function FBShareDialogModeAndroid(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private {}
