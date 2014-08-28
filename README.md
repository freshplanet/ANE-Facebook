Air Native Extension for Facebook (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Facebook SDK](http://developers.facebook.com/docs/guides/mobile/) on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Facebook SDK Versions
---------

* iOS: 3.16.2 (compatible with iOS 5.0 and above)
* Android: 3.6 (compatible with Android 2.2 and above)


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
        <key>FacebookAppID</key>
        <string>{YOUR_FB_ID}</string>

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
                
                <activity android:name="com.facebook.LoginActivity"/>
                <activity android:name="com.freshplanet.ane.AirFacebook.LoginActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"></activity>
                <activity android:name="com.freshplanet.ane.AirFacebook.DialogActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"></activity>
                
            </application>

        </manifest>
    ]]></manifestAdditions>
</android>
```


Documentation
--------

Actionscript documentation is available in HTML format in the *docs* folder.


Samples
--------

A sample project is available in the *sample* folder.
Read HOW-TO.txt walkthrought to set-up and run the sample application.


Build from source
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:
    
```bash
cd /path/to/the/ane

# Setup build configuration
cd build
mv example.build.config build.config
# Edit build.config file to provide your machine-specific paths

# Build the ANE
ant
```


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/titi-us), [Alexis Taugeron](http://alexistaugeron.com) and [Renaud Bardet](http://github.com/renaudbardet). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).


Join the FreshPlanet team - GAME DEVELOPMENT in NYC
------

We are expanding our mobile engineering teams.

FreshPlanet is a NYC based mobile game development firm and we are looking for senior engineers to lead the development initiatives for one or more of our games/apps. We work in small teams (6-9) who have total product control.  These teams consist of mobile engineers, UI/UX designers and product experts.


Please contact Tom Cassidy (tcassidy@freshplanet.com) or apply at http://freshplanet.com/jobs/
