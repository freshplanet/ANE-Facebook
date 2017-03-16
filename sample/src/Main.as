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
package {

    import com.freshplanet.ane.AirFacebook.FBAccessToken;
    import com.freshplanet.ane.AirFacebook.FBDefaultAudience;
    import com.freshplanet.ane.AirFacebook.FBLoginBehaviorAndroid;
    import com.freshplanet.ane.AirFacebook.FBLoginBehaviorIOS;
    import com.freshplanet.ane.AirFacebook.FBProfile;
    import com.freshplanet.ane.AirFacebook.FBShareDialogModeAndroid;
    import com.freshplanet.ane.AirFacebook.FBShareDialogModeIOS;
    import com.freshplanet.ane.AirFacebook.Facebook;
    import com.freshplanet.ane.AirFacebook.appevents.FBEvent;
    import com.freshplanet.ane.AirFacebook.share.FBAppInviteContent;
    import com.freshplanet.ane.AirFacebook.share.FBGameRequestActionType;
    import com.freshplanet.ane.AirFacebook.share.FBGameRequestContent;
    import com.freshplanet.ane.AirFacebook.share.FBGameRequestFilter;
    import com.freshplanet.ane.AirFacebook.share.FBShareLinkContent;
    import com.freshplanet.ui.ScrollableContainer;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.events.Event;
    import flash.net.URLRequestDefaults;
    import flash.net.URLRequestMethod;

    /**
     * Make sure you replace instances of {YOUR_FACEBOOK_ID} in this file and Main.xml
     */
    [SWF(backgroundColor="#057fbc", frameRate='60')]
    public class Main extends Sprite {

        public static var stageWidth:Number = 0;
        public static var indent:Number = 0;

        private var _scrollableContainer:ScrollableContainer = null;

        public function Main() {
            this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        }

        private function _onAddedToStage(event:Event):void {

            this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
            this.stage.align = StageAlign.TOP_LEFT;

            stageWidth = this.stage.stageWidth;
            indent = stage.stageWidth * 0.025;

            _scrollableContainer = new ScrollableContainer(false, true);
            this.addChild(_scrollableContainer);

            if (!Facebook.isSupported) {

                trace("Facebook ANE is NOT supported on this platform!");
                return;
            }

            /**
             * set these up before any use to make sure you catch everything
             */

            Facebook.logEnabled = true;
            Facebook.nativeLogEnabled = true;

            /**
             * init the ANE!
             */

            var ane:Facebook = Facebook.instance;
            ane.init("{YOUR_FACEBOOK_ID}", _initCallback);

            var blocks:Array = [];

            /**
             * methods for performing specific actions (visible to users)
             * mess with the values to mimic your own app!
             */

            blocks.push(new TestBlock("logInWithReadPermissions", function():void {

                ane.logInWithReadPermissions(["email", "user_birthday", "user_friends"],
                                             _logInWithReadPermissionsCallback);
            }));

            blocks.push(new TestBlock("logInWithPublishPermissions", function():void {

                ane.logInWithReadPermissions(["publish_actions"],
                                             _logInWithPublishPermissionsCallback);
            }));

            blocks.push(new TestBlock("accessToken", function():void {

                var token:FBAccessToken = ane.accessToken;
                trace(token);
            }));

            blocks.push(new TestBlock("profile", function():void {

                var profile:FBProfile = ane.profile;
                trace(profile);
            }));

            blocks.push(new TestBlock("canPresentShareDialog", function():void {

                var canPresentShareDialog:Boolean = ane.canPresentShareDialog;
                trace("canPresentShareDialog:" + canPresentShareDialog);
            }));

            blocks.push(new TestBlock("requestWithGraphPath", function():void {

                var graphPath:String = "";
                var parameters:Object = {};

                ane.requestWithGraphPath(graphPath,
                                         parameters,
                                         URLRequestMethod.GET,
                                         _requestWithGraphPathCallback);
            }));

            blocks.push(new TestBlock("shareLinkDialog", function():void {

                var shareLinkContent:FBShareLinkContent = new FBShareLinkContent();

                shareLinkContent.contentDescription = "";
                shareLinkContent.contentTitle = "";
                shareLinkContent.imageUrl = "";

                ane.shareLinkDialog(shareLinkContent,
                                    false,
                                    _shareLinkDialogCallback);
            }));

            blocks.push(new TestBlock("appInviteDialog", function():void {

                var appInviteContent:FBAppInviteContent = new FBAppInviteContent();

                appInviteContent.appLinkUrl = "";
                appInviteContent.previewImageUrl = "";

                ane.appInviteDialog(appInviteContent,
                                    _appInviteDialogCallback);
            }));

            blocks.push(new TestBlock("gameRequestDialog", function():void {

                var gameRequestContent:FBGameRequestContent = new FBGameRequestContent();

                gameRequestContent.title = "";
                gameRequestContent.data = "";
                gameRequestContent.message = "";
                gameRequestContent.objectID = "";
                gameRequestContent.recipientSuggestions = [];
                gameRequestContent.recipients = [];
                gameRequestContent.setActionType(FBGameRequestActionType.SEND);
                gameRequestContent.setFilter(FBGameRequestFilter.APP_USERS);

                ane.gameRequestDialog(gameRequestContent,
                                      true,
                                      _gameRequestDialogCallback);
            }));

            blocks.push(new TestBlock("logEvent", function():void {

                var event:FBEvent = FBEvent.create_ACTIVATED_APP();
                ane.logEvent(event);
            }));

            blocks.push(new TestBlock("logOut", ane.logOut));



            /**
             * add ui to screen
             */

            var nextY:Number = indent;

            for each (var block:TestBlock in blocks) {

                _scrollableContainer.addChild(block);
                block.y = nextY;
                nextY +=  block.height + indent;
            }
        }

        private function _initCallback(...foo):void {

            trace(foo);

            var ane:Facebook = Facebook.instance;

            /**
             * setup methods
             * mess with the values to mimic your own app!
             */

            ane.setDefaultShareDialogMode(FBShareDialogModeIOS.AUTOMATIC,
                    FBShareDialogModeAndroid.AUTOMATIC);

            ane.setLoginBehavior(FBLoginBehaviorIOS.NATIVE,
                    FBLoginBehaviorAndroid.NATIVE_WITH_FALLBACK);

            ane.setDefaultAudience(FBDefaultAudience.FRIENDS);
        }

        private function _logInWithReadPermissionsCallback(success:Boolean, userCancelled:Boolean, error:String = null):void {

            trace("logInWithReadPermissions success:" + success +
                " userCancelled:" + userCancelled +
                " error:" + error)
        }

        private function _logInWithPublishPermissionsCallback(success:Boolean, userCancelled:Boolean, error:String = null):void {

            trace("logInWithPublishPermissions success:" + success +
                " userCancelled:" + userCancelled +
                " error:" + error)
        }

        private function _requestWithGraphPathCallback(graphResponse:Object):void {

        }

        private function _shareLinkDialogCallback(graphResponse:Object):void {

        }

        private function _appInviteDialogCallback(graphResponse:Object):void {

        }

        private function _gameRequestDialogCallback(graphResponse:Object):void {

        }
    }
}
