package com.freshplanet.ane.AirFacebook.share {

    public class FBGameRequestFilter {

        public static const NONE:FBGameRequestFilter = new FBGameRequestFilter(Private, 0);
        public static const APP_USERS:FBGameRequestFilter = new FBGameRequestFilter(Private, 1);
        public static const APP_NON_USERS:FBGameRequestFilter = new FBGameRequestFilter(Private, 2);

        private var _value:int;

        public function FBGameRequestFilter(access:Class, value:int)
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