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
import java.util.List;
import java.util.Map;

import android.content.Intent;
import android.os.Bundle;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.Settings;
import com.freshplanet.ane.AirFacebook.functions.ActivateAppFunction;
import com.freshplanet.ane.AirFacebook.functions.CanPresentOpenGraphDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.CanPresentMessageDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.CanPresentShareDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.CloseSessionAndClearTokenInformationFunction;
import com.freshplanet.ane.AirFacebook.functions.GetAccessTokenFunction;
import com.freshplanet.ane.AirFacebook.functions.GetExpirationTimestampFunction;
import com.freshplanet.ane.AirFacebook.functions.InitFunction;
import com.freshplanet.ane.AirFacebook.functions.IsSessionOpenFunction;
import com.freshplanet.ane.AirFacebook.functions.OpenSessionWithPermissionsFunction;
import com.freshplanet.ane.AirFacebook.functions.PresentMessageDialogWithLinkAndParamsFunction;
import com.freshplanet.ane.AirFacebook.functions.ReauthorizeSessionWithPermissionsFunction;
import com.freshplanet.ane.AirFacebook.functions.RequestWithGraphPathFunction;
import com.freshplanet.ane.AirFacebook.functions.SetUsingStage3dFunction;
import com.freshplanet.ane.AirFacebook.functions.ShareLinkDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.ShareOpenGraphDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.ShareStatusDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.WebDialogFunction;
import com.freshplanet.ane.AirFacebook.functions.OpenDeferredAppLinkFunction;

public class AirFacebookExtensionContext extends FREContext
{
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
		functions.put("canPresentShareDialog", new CanPresentShareDialogFunction());
		functions.put("shareStatusDialog", new ShareStatusDialogFunction());
		functions.put("shareLinkDialog", new ShareLinkDialogFunction());
		functions.put("canPresentOpenGraphDialog", new CanPresentOpenGraphDialogFunction());
		functions.put("shareOpenGraphDialog", new ShareOpenGraphDialogFunction());
		functions.put("canPresentMessageDialog", new CanPresentMessageDialogFunction());
		functions.put("presentMessageDialogWithLinkAndParams", new PresentMessageDialogWithLinkAndParamsFunction());
		functions.put("webDialog", new WebDialogFunction());
		functions.put("activateApp", new ActivateAppFunction());
		functions.put("setUsingStage3D", new SetUsingStage3dFunction());
		functions.put("openDeferredAppLink", new OpenDeferredAppLinkFunction());
		return functions;	
	}
	
	private String _appID;
	private Session _session;
	public boolean usingStage3D = false;
	
	public void init(String appID, Boolean legacyMode)
	{
		_appID = appID;
		
		Session session = getSession();
		if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED))
		{
			Session.setActiveSession(session);
            Settings.setPlatformCompatibilityEnabled(legacyMode);
			try
			{
				session.openForRead(null);
			}
			catch (UnsupportedOperationException exception)
			{
				String error = exception != null ? exception.toString() : "null exception";
				AirFacebookExtension.log("ERROR - Couldn't open session from cached token: " + error);
			}
		}
	}
	
	public Session getSession()
	{
		if (_session == null)
		{
			_session = new Session.Builder(getActivity().getApplicationContext()).setApplicationId(_appID).build();
		}
		
		return _session;
	}
	
	public void closeSessionAndClearTokenInformation()
	{
		if (_session != null)
		{
			_session.closeAndClearTokenInformation();
			_session = null;
		}
	}
	
	public void launchLoginActivity(List<String> permissions, String type, Boolean reauthorize)
	{
		Intent i = new Intent(getActivity().getApplicationContext(), LoginActivity.class);
		i.putExtra(LoginActivity.extraPrefix+".permissions", permissions.toArray(new String[permissions.size()]));
		i.putExtra(LoginActivity.extraPrefix+".type", type);
		i.putExtra(LoginActivity.extraPrefix+".reauthorize", reauthorize);
		getActivity().startActivity(i);
	}
	
	public void launchDialogActivity(String method, Bundle parameters, String callback)
	{
		Intent i = new Intent(getActivity().getApplicationContext(), WebDialogActivity.class);
		i.putExtra(WebDialogActivity.extraPrefix+".method", method);
		i.putExtra(WebDialogActivity.extraPrefix+".parameters", parameters);
		i.putExtra(WebDialogActivity.extraPrefix+".callback", callback);
		getActivity().startActivity(i);
	}
	
	public void launchRequestThread(String graphPath, Bundle parameters, String httpMethod, String callback)
	{
		new RequestThread(this, graphPath, parameters, httpMethod, callback).start();
	}
}
