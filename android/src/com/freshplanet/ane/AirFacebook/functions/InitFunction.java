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

import android.content.Context;
import android.content.SharedPreferences;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.AccessToken;
import com.facebook.Session;
import com.facebook.SessionState;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

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
		
		Context context = arg0.getActivity().getApplicationContext() ;
		
		Session session = new Session.Builder(context).setApplicationId(appID).build();
		
		// migration from previous SDK's token if any
		SharedPreferences sdk2SavedSession = context.getSharedPreferences("facebook-session", Context.MODE_PRIVATE);
		String sdk2Token = sdk2SavedSession.getString("access_token", null) ;
		if(sdk2Token != null) {

			AirFacebookExtension.log("INFO - InitFunction, SDK 2.0 token detected");
			
		    // Clear the token info
		    SharedPreferences.Editor editor = sdk2SavedSession.edit();
		    editor.putString("access_token", null);
		    editor.commit();    
		    // Create an AccessToken object for importing
		    // just pass in the access token and take the
		    // defaults on other values
		    AccessToken accessToken = AccessToken.createFromExistingAccessToken(sdk2Token, null, null, null, null);
		    
		    // statusCallback: Session.StatusCallback implementation
		    session.open(accessToken, new Session.StatusCallback() {
										@Override
										public void call(Session session, SessionState state, Exception exception) {
											if ( exception != null) {
												AirFacebookExtension.log("INFO - InitFunction, Session migration failed with error : " + exception.toString() );
												// reset the session, will direct the user into the login flow again
												//session = new Session.Builder(arg0.getActivity().getApplicationContext()).setApplicationId(appID).build();
											}
											else
											{
											    Session.setActiveSession(session);
											    if ( state.equals(SessionState.OPENED_TOKEN_UPDATED) )
													AirFacebookExtension.log("INFO - InitFunction, Session opened from migrated token, the token have been updated");
												else
													AirFacebookExtension.log("INFO - InitFunction, Session opened from migrated token");
											}
										}
									} ) ;
		    
		}

		AirFacebookExtensionContext.session = session;
		
		AirFacebookExtension.log("INFO - InitFunction, session=" + AirFacebookExtensionContext.session);

		if (SessionState.CREATED_TOKEN_LOADED.equals(session.getState())) {
			Session.setActiveSession(session);
			AirFacebookExtension.log("INFO - cachedAccessToken=" + session.getAccessToken());
			session.openForRead(null);
		}
		
		return null;
	}
}