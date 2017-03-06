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
     * This class represents a basic Facebook profile.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/Profile/
     */
    public class FBProfile {

        /**
         * The first name of the profile. Can be null.
         */
        public var firstName:String = null;

        /**
         * The last name of the profile. Can be null.
         */
        public var lastName:String = null;

        /**
         * The link for this profile. Can be null.
         */
        public var linkUrl:String = null;

        /**
         * The middle name of the profile. Can be null.
         */
        public var middleName:String = null;

        /**
         * The name of the profile. Can be null.
         */
        public var name:String = null;

        /**
         * The last time the profile data was fetched.
         * (NOTE: IOS only)
         */
        public var refreshDate:Number = 0;

        /**
         * The id of the profile.
         */
        public var userID:String = null;

        /**
         *
         * @return
         */
        public function toString():String {

            var str:String = "[FBAccessToken";

            str += " firstName:'" + firstName + "'";
            str += " lastName:'" + lastName + "'";
            str += " linkUrl:'" + linkUrl + "'";
            str += " middleName:'" + middleName + "'";
            str += " name:'" + name + "'";
            str += " refreshDate:'" + refreshDate + "'";
            str += " userID:'" + userID + "'";

            return str + "]";
        }
    }
}