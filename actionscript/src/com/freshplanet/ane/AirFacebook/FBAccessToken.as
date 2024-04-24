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
     * This class represents an immutable access token for using Facebook APIs.
     * It also includes associated metadata such as expiration date and permissions.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/AccessToken/
     */
    public class FBAccessToken {

        /**
         * The ID of the Facebook Application associated with this access token
         */
        public var appID:String = null;

        /**
         * The permissions that were declined when the token was obtained; may be null if permission set is unknown
         */
        public var declinedPermissions:Array = null;

        /**
         * The expiration date associated with the token; if null, an infinite expiration time is assumed (but will become correct when the token is refreshed)
         */
        public var expirationDate:Number = 0;

        /**
         * The permissions that were requested when the token was obtained (or when it was last reauthorized); may be null if permission set is unknown
         */
        public var permissions:Array = null;

        /**
         * The last time the token was refreshed (or when it was first obtained); if null, the current time is used.
         */
        public var refreshDate:Number = 0;

        /**
         * The access token string obtained from Facebook
         */
        public var tokenString:String = null;

        /**
         * The id of the user
         */
        public var userID:String;

        /**
         * Flag to determine if token is limited login authentification JWT token
         */
        public var isLimitedLogin:Boolean;

        /**
         *
         * @return
         */
        public function toString():String {

            var str:String = "[FBAccessToken";

            str += " appID:'" + appID + "'";
            str += " declinedPermissions:'" + (declinedPermissions ? declinedPermissions.join(",") : "null") + "'";
            str += " expirationDate:'" + expirationDate + "'";
            str += " permissions:'" + (permissions ? permissions.join(",") : "null") + "'";
            str += " refreshDate:'" + refreshDate + "'";
            str += " tokenString:'" + tokenString + "'";
            str += " userID:'" + userID + "'";
            str += " isLimitedLogin:'" + isLimitedLogin + "'";

            return str + "]";
        }
    }
}