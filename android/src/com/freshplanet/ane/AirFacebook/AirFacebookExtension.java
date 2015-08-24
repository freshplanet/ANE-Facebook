package com.freshplanet.ane.AirFacebook;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class AirFacebookExtension implements FREExtension
{
	
	public static String TAG = "AirFacebook";
	public static Boolean nativeLogEnabled = true;
	
	public static AirFacebookExtensionContext context;

	public FREContext createContext(String extId)
	{
		return context = new AirFacebookExtensionContext();
	}

	public void dispose()
	{
		context = null;
	}
	
	public void initialize() {}
	
	public static void log(String message)
	{
		as3Log(message);
		nativeLog(message, "NATIVE");
	}

	public static void as3Log(String message)
	{
		if (context != null && message != null) {

			context.dispatchStatusEventAsync("LOGGING", message);
		}
	}

	public static void nativeLog(String message, String prefix)
	{
		if (nativeLogEnabled) {

			Log.i(TAG, "[" + prefix + "] " + message);
		}
	}
	
	public static int getResourceId(String name)
	{
		return context != null ? context.getResourceId(name) : 0;
	}
}
