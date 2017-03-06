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
     * Describes the content that will be displayed by the AppInviteDialog.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/AppInviteContent/
     */
    public class FBAppInviteContent {

        /**
         * App Link for what should be opened when the recipient clicks on the install/play button on the app invite page.
         * @required
         */
        public var appLinkUrl:String = null;

        /**
         * A url to an image to be used in the invite.
         */
        public var previewImageUrl:String = null;

        /**
         *
         * @return
         */
        public function toString():String {

            var str:String = "[FBAppInviteContent";

            str += " appLinkUrl:'" + appLinkUrl + "'";
            str += " previewImageUrl:'" + previewImageUrl + "'";

            return str + "]";
        }
    }
}
