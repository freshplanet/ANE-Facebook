package com.freshplanet.ane.AirFacebook.share {

    public class FBGameRequestActionType {

        public static const NONE:FBGameRequestActionType = new FBGameRequestActionType(Private, 0);
        public static const SEND:FBGameRequestActionType = new FBGameRequestActionType(Private, 1);
        public static const ASK_FOR:FBGameRequestActionType = new FBGameRequestActionType(Private, 2);
        public static const TURN:FBGameRequestActionType = new FBGameRequestActionType(Private, 3);

        private var _value:int;

        public function FBGameRequestActionType(access:Class, value:int)
        {
            if(access != Private){
                throw new Error("Private constructor call!");
            }

            _value = value;
        }

        public function get value():int
        {
            return _value;
        }
    }
}

final class Private{}