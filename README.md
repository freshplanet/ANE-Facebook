Air Native Extension for Facebook (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Facebook SDK](http://developers.facebook.com/docs/guides/mobile/) on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Facebook SDK
---------

This ANE contains the new Facebook SDK for iOS (3.1). It still uses the old Facebook SDK for Android (the transition to 3.0 is a work in progress). The Actionscript API is based on the new Facebook SDK API.


Installation
---------

The ANE binary (AirFacebook.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).

On iOS:

* as explained [here](http://developers.facebook.com/docs/mobile/ios/build/), you will need to add some Info.plist additions in your application descriptor:
    
    ```xml
    <iPhone>
        
        <InfoAdditions><![CDATA[

            <key>CFBundleURLTypes</key>
            <array>
                <dict>
                    <key>CFBundleURLSchemes</key>
                        <array>
                            <string>fb{YOUR_FB_ID}</string>
                        </array>
                </dict>
            </array>

        ]]></InfoAdditions>

    </iPhone>
    ```

On Android:

* you will need to add the following activities and permission in your application descriptor:

    ```xml
    <android>
        <manifestAdditions><![CDATA[
            <manifest android:installLocation="auto">
                
                ...

                <uses-permission android:name="android.permission.INTERNET"/>
                
                ...

                <application>

                    ...
                    
                    <activity android:name="com.freshplanet.ane.AirFacebook.LoginActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"></activity>
                    <activity android:name="com.freshplanet.ane.AirFacebook.DialogActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"></activity>
                    <activity android:name="com.freshplanet.ane.AirFacebook.ExtendAccessTokenActivity"></activity>
                    
                </application>

            </manifest>
        ]]></manifestAdditions>
    </android>
    ```


Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Documentation
--------
Documentation is embbeded in the ane to provide inline asdoc in Flash Builder and other compatible IDEs

You can generate a readable html documentation from the ant build script (see Build Script above):

   ant asdoc


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/titi-us), [Alexis Taugeron](http://alexistaugeron.com) and [Renaud Bardet](http://github.com/renaudbardet). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
