package com.freshplanet.natExt;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class FBExtension implements FREExtension {

	public static FREContext context;
	
	/**
	 * Create the context (AS to Java).
	 */
	public FREContext createContext(String extId) {
		Log.d("as3c2dm", "createContext extId: " + extId);
		return context = new FBExtensionContext();
	}

	/**
	 * Dispose the context.
	 */
	public void dispose() {
		Log.d("as3c2dm", "dispose");
		context = null;
	}
	
	/**
	 * Initialize the context.
	 * Doesn't do anything for now.
	 */
	public void initialize() {
		Log.d("as3c2dm", "initialize");
	}
}
