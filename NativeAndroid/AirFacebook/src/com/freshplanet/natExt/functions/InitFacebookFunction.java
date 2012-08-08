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

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.facebook.android.Facebook;
import com.freshplanet.natExt.FBExtensionContext;

public class InitFacebookFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		arg0.dispatchStatusEventAsync("INIT_FACEBOOK", "STARTED");

		
		arg0.dispatchStatusEventAsync("INIT_FACEBOOK ", "args "+Integer.toString(arg1.length));
		
		String appId = null;
		try {
			appId = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		}
		
		String accessToken = null;
		
		try {
			if (arg1[1] != null)
			{
				accessToken = arg1[1].getAsString();
			}
		} catch (IllegalStateException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		}

		Log.d("as2fb", "acces "+accessToken);

		Long expirationTimestamp = (long) 0;
		
		try {
			if (arg1[2] != null)
			{
				String expirationTimestampString = arg1[2].getAsString();
				Log.d("as2fb", "expires "+expirationTimestampString);

				expirationTimestamp = Long.valueOf(expirationTimestampString);
			}
		} catch (IllegalStateException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		} catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("INIT_FACEBOOK", e.getMessage());
		}

		
		
		FBExtensionContext.facebook = new Facebook(appId);
		if (accessToken != null && expirationTimestamp != 0)
		{
			FBExtensionContext.facebook.setAccessToken(accessToken);
			FBExtensionContext.facebook.setAccessExpires(expirationTimestamp);
		}
		
		
		arg0.dispatchStatusEventAsync("INIT_FACEBOOK", "DONE");

		return null;
	}

}
