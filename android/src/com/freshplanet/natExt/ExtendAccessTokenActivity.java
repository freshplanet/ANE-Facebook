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

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.android.DialogError;
import com.facebook.android.SessionStore;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.Facebook.ServiceListener;
import com.facebook.android.FacebookError;

public class ExtendAccessTokenActivity extends Activity implements ServiceListener, DialogListener
{
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		boolean res = false;
		if (!FBExtensionContext.facebook.isSessionValid())
		{
			res = true;
			FBExtensionContext.facebook.authorize(this, this);
		}
		else if (FBExtensionContext.facebook.shouldExtendAccessToken())
		{
			res = FBExtensionContext.facebook.extendAccessTokenIfNeeded(this, this);
		}
		
		if (!res)
		{
			String access_token = FBExtensionContext.facebook.getAccessToken();
			long access_expires = FBExtensionContext.facebook.getAccessExpires();
			FBExtension.context.dispatchStatusEventAsync("USER_LOGGED_IN", access_token+'&'+Long.toString(access_expires));
			finish();
		}
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		FBExtensionContext.facebook.authorizeCallback(requestCode, resultCode, data);
		finish();
	}

	@Override
	public void onComplete(Bundle values)
	{
		SessionStore.save(FBExtensionContext.facebook, FBExtension.context.getActivity().getApplicationContext());
		String access_token = FBExtensionContext.facebook.getAccessToken();
		long access_expires = FBExtensionContext.facebook.getAccessExpires();
		FBExtension.context.dispatchStatusEventAsync("ACCESS_TOKEN_REFRESHED", access_token+"&"+Long.toString(access_expires));
		finish();
	}
	
	@Override
	public void onFacebookError(FacebookError e)
	{
		FBExtension.context.dispatchStatusEventAsync("ACCESS_TOKEN_FACEBOOK_ERROR", "success");
		finish();
	}

	@Override
	public void onError(Error e)
	{
		FBExtension.context.dispatchStatusEventAsync("ACCESS_TOKEN_ERROR", "success");	
		finish();
	}

	@Override
	public void onError(DialogError e)
	{
		FBExtension.context.dispatchStatusEventAsync("USER_LOG_IN_ERROR", e.getMessage());	
		finish();
	}

	@Override
	public void onCancel()
	{
		FBExtension.context.dispatchStatusEventAsync("USER_LOG_IN_CANCEL", "null");
		finish();
	}
}