Air Native Extension for Facebook (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Facebook SDK](http://developers.facebook.com/docs/guides/mobile/) on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com). FreshPlanet is no longer updating this ANE. I will try to update it as soon as possible to newest SDKs versions.


Facebook SDK Versions
---------

* iOS: 3.23.2 
* Android: 3.23.1


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

You MUST use Java 1.6 otherwise in android context will be null (probably bug in Adobe AIR SDK). On OSX you can call "export JAVA_HOME=`/usr/libexec/java_home -v 1.6`" without " to set JAVA_HOME properly.

NOTE:
Don't forget to create local.properties file in android folder with sdk.dir pointing to android-15 sdk. (I will update build scripts to remove this step.)

Facebook android sdk use (deprecated)
---------

This sdk is using staticaly linked elements. We had to modify all the calls to the com.facebook.android.R package by a custom function that is doing the linking at runtime:
import com.freshplanet.ane.AirFacebook.AirFacebookExtension
and use AirFacebookExtension.getResourceId("nameOfTheRessource") or AirFacebookExtension.getResourceIds("nameOfTheRessource")

Also an error when linking the ressources into the app, I had to rename the res/values/styles.xml to res/values/style.xml


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/titi-us), [Alexis Taugeron](http://alexistaugeron.com) and [Renaud Bardet](http://github.com/renaudbardet). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

