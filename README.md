Air Native Extension for Facebook (iOS + Android)
======================================

This is an [AIR Native Extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for the Facebook SDK on [iOS](https://developers.facebook.com/docs/ios) and [Android](https://developers.facebook.com/docs/android). It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop 2](https://www.songpop2.com/).


Facebook SDK Versions
---------

* iOS: 4.19.0
* Android: 4.19.0

Installation
---------

The ANE binary (AirFacebook.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)). See it within our sample project's app descriptor [here](https://github.com/freshplanet/ANE-Facebook/blob/master/sample/src/Main.xml#L138).

```xml
<extensions>
    ...
    <extensionID>com.freshplanet.ane.AirFacebook</extensionID>
</extensions>
```

**iOS**

Be sure to follow steps [1](https://developers.facebook.com/docs/ios/getting-started/#settings) and [4](https:developers.facebook.com/docs/ios/getting-started/#xcode) of the [Getting Started with the Facebook SDK for iOS](https:developers.facebook.com/docs/ios/getting-started/) guide.

Check out the sample project [here](https://github.com/freshplanet/ANE-Facebook/blob/master/sample/src/Main.xml#L70) for app descriptor inclusions.

**Android**

You will need to add the following activities and permission in your application descriptor:

```xml
<android>
    ...
    <manifestAdditions><![CDATA[
        <manifest android:installLocation="auto">
            ...
            <uses-permission android:name="android.permission.INTERNET"/>
            <application>
                ...
                <meta-data android:name="com.facebook.sdk.ApplicationId" 
                           android:value="fb{YOUR_FB_APPLICATION_ID}"/>

                <activity android:name="com.facebook.FacebookActivity" 
                          android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="{YOUR_FB_APPLICATION_NAME}" />

                <activity android:name="com.freshplanet.ane.AirFacebook.LoginActivity" 
                          android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />

                <activity android:name="com.freshplanet.ane.AirFacebook.ShareDialogActivity" 
                          android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />

                <activity android:name="com.freshplanet.ane.AirFacebook.AppInviteActivity" 
                          android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />

                <activity android:name="com.freshplanet.ane.AirFacebook.GameRequestActivity" 
                          android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />

                <!-- If you're sharing links, images or video via the Facebook for Android app, you also need to declarthe   FacebookContentProvider in the manifest. -->
                <provider android:authorities="com.facebook.app.FacebookContentProvider{YOUR_FB_APPLICATION_ID}" 
                          android:name="com.facebook.FacebookContentProvider" 
                          android:exported="true"/>
            </application>
        </manifest>
    ]]></manifestAdditions>
</android>
```

You can check out our example of this in our sample project [here](https://github.com/freshplanet/ANE-Facebook/blob/mastesample/src/Main.xml#L19).

**NOTE:** It is important to prefix YOUR_FB_APP_ID with "fb" in `<meta-data>` (and ONLY in `<meta-data>`) tag, because obug in Android manifest file (http://stackoverflow.com/questions/16156856/android-facebook-applicationid-cannot-be-null)Facebook SDK code in this ANE was modified to recognize FB_APP_ID prefixed with "fb".

Using the ANE
---------

Once installed you can initialize the ANE...

```actionscript
Facebook.instance.init("0123456789", _initCallback);
```

and it will be ready to go! Check out [our sample code](https://github.com/freshplanet/ANE-Facebook/blob/master/sample/src/Main.as) to aid you.

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

This ANE has been originally written by [Thibaut Crenn](https://github.com/titi-us), [Alexis Taugeron](http://alexistaugeron.com), [Renaud Bardet](http://github.com/renaudbardet) and [Adam Schlesinger](https://github.com/AdamFP). Rewrites and modifications to version SDK 4.x were made by [Ján Horváth](https://github.com/nodrock).

