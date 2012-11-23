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

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.Facebook.ServiceListener;
import com.facebook.android.FacebookError;
import com.facebook.android.SessionStore;

public class ExtendAccessTokenActivity extends Activity implements ServiceListener, DialogListener
{
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		boolean isRefreshNeeded = false;
		if (!AirFacebookExtensionContext.facebook.isSessionValid())
		{
			isRefreshNeeded = true;
			AirFacebookExtensionContext.facebook.authorize(this, this);
		}
		else if (AirFacebookExtensionContext.facebook.shouldExtendAccessToken())
		{
			isRefreshNeeded = AirFacebookExtensionContext.facebook.extendAccessTokenIfNeeded(this, this);
		}
		
		if (!isRefreshNeeded)
		{
			finish();
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		AirFacebookExtensionContext.facebook.authorizeCallback(requestCode, resultCode, data);
		finish();
	}

	public void onComplete(Bundle values)
	{
		SessionStore.save(AirFacebookExtensionContext.facebook, AirFacebookExtension.context.getActivity().getApplicationContext());
		finish();
	}
	
	public void onFacebookError(FacebookError e)
	{
		finish();
	}

	public void onError(DialogError e)
	{
		finish();
	}

	public void onCancel()
	{
		finish();
	}
	
	public void onError(Error e)
	{
		finish();
	}
}