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

package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;
import com.facebook.LoggingBehavior;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.Settings;

public class InitFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve application ID
		String appID = null;
		try
		{
			appID = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		AirFacebookExtension.log("INFO - InitFunction, appID=" + appID);

		Session session = new Session.Builder(arg0.getActivity().getApplicationContext()).setApplicationId(appID).build();
		
		if (session == null) {
			AirFacebookExtension.log("INFO - InitFunction, session is null");
		} else {
			AirFacebookExtension.log("INFO - InitFunction, session=" + session);
		}

		AirFacebookExtensionContext.session = session;
		
		AirFacebookExtension.log("INFO - InitFunction, session=" + AirFacebookExtensionContext.session);

		if (SessionState.CREATED_TOKEN_LOADED.equals(session.getState())) {
			AirFacebookExtension.log("INFO - InitFunction, test 21");
			Session.setActiveSession(session);
			AirFacebookExtension.log("INFO - InitFunction, test 22");
			AirFacebookExtension.log("INFO - cachedAccessToken=" + session.getAccessToken());
			session.openForRead(null);
		}
		
		return null;
	}
}