package com.freshplanet.ane.AirFacebook.share {

    public class FBGameRequestContent {

        public function FBGameRequestContent() {}

        private var _actionType:uint;
        public var data:String;
        private var _filters:uint;
        public var message:String;
        public var objectID:String;

        /**
         * users the dialog will be targeted at (will only use the 1st user on Android)
         */
        public var recipients:Array;

        public var recipientSuggestions:Array;
        public var title:String;

        public function get actionType():uint {
            return _actionType;
        }

        public function get filters():uint {
            return _filters;
        }

        public function setActionType(val:FBGameRequestActionType) {
            _actionType = val.value;
        }

        public function setFilter(val:FBGameRequestFilter) {
            _filters = val.value;
        }
    }
}
