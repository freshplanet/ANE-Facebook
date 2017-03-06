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
     * Certain operations such as publishing a status or publishing a photo require an audience.
     * When the user grants an application permission to perform a publish operation, a default
     * audience is selected as the publication ceiling for the application. This enumerated value
     * allows the application to select which audience to ask the user to grant publish permission for.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/DefaultAudience/
     */
    public class FBDefaultAudience {

        // --------------------------------------------------------------------------------------//
        //																						 //
        // 									   PUBLIC API										 //
        // 																						 //
        // --------------------------------------------------------------------------------------//

        /**
         * Indicates that the user's friends are able to see posts made by the application.
         */
        public static const FRIENDS:FBDefaultAudience = new FBDefaultAudience(Private, 0);

        /**
         * Indicates only the user is able to see posts made by the application.
         */
        public static const ONLY_ME:FBDefaultAudience = new FBDefaultAudience(Private, 1);

        /**
         * Indicates that all Facebook users are able to see posts made by the application.
         */
        public static const EVERYONE:FBDefaultAudience = new FBDefaultAudience(Private, 2);

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

        private var _value:int = 0; // FRIENDS

        /**
         * "private" constructor
         * @param access
         * @param value
         */
        public function FBDefaultAudience(access:Class, value:int) {

            if (access != Private)
                throw new Error("Private constructor call!");

            _value = value;
        }
    }
}

final class Private {}
