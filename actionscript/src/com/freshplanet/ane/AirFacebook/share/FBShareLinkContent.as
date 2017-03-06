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
     * Describes link content to be shared.
     *
     * @see FBShareContent
     * @see http://developers.facebook.com/docs/reference/android/current/class/ShareLinkContent/
     */
    public class FBShareLinkContent extends FBShareContent{

        /**
         * The description of the link. If not specified, this field is automatically populated by information scraped from the link, typically the title of the page.
         */
        public var contentDescription:String = null;

        /**
         * The title to display for this link.
         */
        public var contentTitle:String = null;

        /**
         * The URL of a picture to attach to this content.
         */
        public var imageUrl:String = null;

        /**
         *
         * @return
         */
        override public function toString():String {

            var str:String = "[FBShareLinkContent";

            str += " contentDescription:'" + contentDescription + "'";
            str += " contentTitle:'" + contentTitle + "'";
            str += " imageUrl:'" + imageUrl + "'";
            str += " " + super.toString();

            return str + "]";
        }
    }
}
