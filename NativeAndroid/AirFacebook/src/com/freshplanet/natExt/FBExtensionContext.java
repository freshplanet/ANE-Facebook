//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.natExt;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.facebook.android.Facebook;
import com.freshplanet.natExt.functions.DeleteInvitesFunction;
import com.freshplanet.natExt.functions.ExtendAccessTokenIfNeededFunction;
import com.freshplanet.natExt.functions.HandleOpenURLFunction;
import com.freshplanet.natExt.functions.InitFacebookFunction;
import com.freshplanet.natExt.functions.LoginFacebookFunction;
import com.freshplanet.natExt.functions.LogoutFacebookFunction;
import com.freshplanet.natExt.functions.OpenDialogFunction;
import com.freshplanet.natExt.functions.RequestWithGraphPathFunction;

public class FBExtensionContext extends FREContext {

	public static Facebook facebook;
	public static FBLoginActivity facebookLoginActivity;
	private static String TAG = "as3fb";

	
	public FBExtensionContext() {
		Log.d(TAG, "Context.FBExtensionContext");
	}
	
	@Override
	public void dispose() {
		Log.d(TAG, "Context.dispose");
		FBExtension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() {
		Log.d(TAG, "Context.getFunctions");
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("initFacebook", new InitFacebookFunction());
		functionMap.put("login", new LoginFacebookFunction());
		functionMap.put("handleOpenURL", new HandleOpenURLFunction());
		functionMap.put("extendAccessTokenIfNeeded", new ExtendAccessTokenIfNeededFunction());
		functionMap.put("requestWithGraphPath", new RequestWithGraphPathFunction());
		functionMap.put("openDialog", new OpenDialogFunction());
		functionMap.put("logout", new LogoutFacebookFunction());
		functionMap.put("deleteRequests", new DeleteInvitesFunction());
		return functionMap;	
	}

}
