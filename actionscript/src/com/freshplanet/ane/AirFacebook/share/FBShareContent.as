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
     * Provides the base class for content to be shared. Contains all common methods for the different types of content.
     *
     * @see http://developers.facebook.com/docs/reference/android/current/class/ShareContent/
     */
    public class FBShareContent {

        /**
         * URL for the content being shared. This URL will be checked for app link meta tags for linking in platform specific ways.
         */
        public var contentUrl:String = null;

        /**
         * List of Ids for taggable people to tag with this content.
         */
        public var peopleIds:Array = null;

        /**
         * The Id for a place to tag with this content.
         */
        public var placeId:String = null;
        /**
         * A value to be added to the referrer URL when a person follows a link from this shared content on feed.
         */
        public var ref:String = null;

        /**
         *
         * @return
         */
        public function toString():String {

            var str:String = "[FBShareContent";

            str += " contentUrl:'" + contentUrl + "'";
            str += " peopleIds:'" + peopleIds + "'";
            str += " placeId:'" + placeId + "'";
            str += " ref:'" + ref + "'";

            return str + "]";
        }
    }
}
