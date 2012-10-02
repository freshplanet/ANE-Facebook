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

package com.freshplanet.natExt.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.android.Facebook;
import com.facebook.android.SessionStore;
import com.freshplanet.natExt.FBExtensionContext;

public class InitFacebookFunction implements FREFunction
{
	@Override
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
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
		}
		
		// Create Facebook object
		FBExtensionContext.facebook = new Facebook(appID);
		
		// Restore previous token if possible
		SessionStore.restore(FBExtensionContext.facebook, arg0.getActivity().getApplicationContext());
		
		return null;
	}
}