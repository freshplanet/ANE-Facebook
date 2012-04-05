
package com.freshplanet.natExt;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.facebook.android.Facebook;
import com.freshplanet.natExt.functions.ExtendAccessTokenIfNeededFunction;
import com.freshplanet.natExt.functions.HandleOpenURLFunction;
import com.freshplanet.natExt.functions.InitFacebookFunction;
import com.freshplanet.natExt.functions.LoginFacebookFunction;
import com.freshplanet.natExt.functions.OpenDialogFunction;
import com.freshplanet.natExt.functions.RequestWithGraphPathFunction;

public class FBExtensionContext extends FREContext {

	public static Facebook facebook;
	public static FBLoginActivity facebookLoginActivity;
	
	public FBExtensionContext() {
		Log.d("as3c2dm", "Context.C2DMExtensionContext");
	}
	
	@Override
	public void dispose() {
		Log.d("as3c2dm", "Context.dispose");
		FBExtension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() {
		Log.d("as3c2dm", "Context.getFunctions");
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("initFacebook", new InitFacebookFunction());
		functionMap.put("login", new LoginFacebookFunction());
		functionMap.put("handleOpenURL", new HandleOpenURLFunction());
		functionMap.put("extendAccessTokenIfNeeded", new ExtendAccessTokenIfNeededFunction());
		functionMap.put("requestWithGraphPath", new RequestWithGraphPathFunction());
		functionMap.put("openDialog", new OpenDialogFunction());
		return functionMap;	
	}

}
