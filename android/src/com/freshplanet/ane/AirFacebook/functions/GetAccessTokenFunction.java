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
import com.adobe.fre.FREObject;
import com.facebook.AccessToken;

public class GetAccessTokenFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		AccessToken accessToken = AccessToken.getCurrentAccessToken();
		if(accessToken != null){

			try {
				FREObject result = FREObject.newObject("com.freshplanet.ane.AirFacebook.FBAccessToken", null);
				result.setProperty("appID", FREObject.newObject(accessToken.getApplicationId()));
				result.setProperty("declinedPermissions", getFREArrayFromSet(accessToken.getDeclinedPermissions()));
				result.setProperty("expirationDate", FREObject.newObject((double) (accessToken.getExpires().getTime() / 1000)));
				result.setProperty("permissions", getFREArrayFromSet(accessToken.getPermissions()));
				result.setProperty("refreshDate", FREObject.newObject((double)(accessToken.getLastRefresh().getTime() / 1000)));
				result.setProperty("tokenString", FREObject.newObject(accessToken.getToken()));
				result.setProperty("userID", FREObject.newObject(accessToken.getUserId()));
				return result;
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		}

		return null;
	}
}