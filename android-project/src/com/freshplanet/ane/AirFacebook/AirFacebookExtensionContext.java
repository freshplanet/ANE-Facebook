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

package com.freshplanet.ane.AirFacebook;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.facebook.android.Facebook;
import com.freshplanet.ane.AirFacebook.functions.CloseSessionAndClearTokenInformationFunction;
import com.freshplanet.ane.AirFacebook.functions.DialogFunction;
import com.freshplanet.ane.AirFacebook.functions.GetAccessTokenFunction;
import com.freshplanet.ane.AirFacebook.functions.GetExpirationTimestampFunction;
import com.freshplanet.ane.AirFacebook.functions.InitFunction;
import com.freshplanet.ane.AirFacebook.functions.IsSessionOpenFunction;
import com.freshplanet.ane.AirFacebook.functions.OpenSessionWithPermissionsFunction;
import com.freshplanet.ane.AirFacebook.functions.PublishInstallFunction;
import com.freshplanet.ane.AirFacebook.functions.ReauthorizeSessionWithPermissionsFunction;
import com.freshplanet.ane.AirFacebook.functions.RequestWithGraphPathFunction;
import com.facebook.Session;

public class AirFacebookExtensionContext extends FREContext
{
	public static Facebook facebook;
	public static LoginActivity facebookLoginActivity;

	public static Session session;
	
	@Override
	public void dispose()
	{
		AirFacebookExtension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		
		functions.put("init", new InitFunction());
		functions.put("getAccessToken", new GetAccessTokenFunction());
		functions.put("getExpirationTimestamp", new GetExpirationTimestampFunction());
		functions.put("isSessionOpen", new IsSessionOpenFunction());
		functions.put("openSessionWithPermissions", new OpenSessionWithPermissionsFunction());
		functions.put("reauthorizeSessionWithPermissions", new ReauthorizeSessionWithPermissionsFunction());
		functions.put("closeSessionAndClearTokenInformation", new CloseSessionAndClearTokenInformationFunction());
		functions.put("requestWithGraphPath", new RequestWithGraphPathFunction());
		functions.put("dialog", new DialogFunction());
		functions.put("publishInstall", new PublishInstallFunction());
		return functions;	
	}
}