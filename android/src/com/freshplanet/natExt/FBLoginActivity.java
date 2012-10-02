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
import android.view.KeyEvent;
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.facebook.android.SessionStore;

public class FBLoginActivity extends Activity implements DialogListener
{	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext freContext = FBExtension.context;
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(freContext.getResourceId("layout.fb_main"));
		
		// Get extra values
		Bundle values = this.getIntent().getExtras();
		String[] permissions = values.getStringArray("permissions");
		Boolean forceAuthorize = values.getBoolean("forceAuthorize", false);
		
		// Authorize Facebook session if necessary
		if(forceAuthorize || !FBExtensionContext.facebook.isSessionValid())
		{
			FBExtensionContext.facebook.authorize(this, permissions, this);
		}
		else
		{
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
		FBExtension.context.dispatchStatusEventAsync("USER_LOGGED_IN", access_token+"&"+Long.toString(access_expires));
		finish();
	}

	@Override
	public void onFacebookError(FacebookError e)
	{
		FBExtension.context.dispatchStatusEventAsync("USER_LOG_IN_FB_ERROR", e.getMessage());	
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

	@Override
	public void onBackPressed()
	{
		FBExtension.context.dispatchStatusEventAsync("USER_LOG_IN_CANCEL", "null");
		finish();
	}
	
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event)
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK)
	    {
	    	onBackPressed();
	        return true;
	    }
	    
	    return super.onKeyUp(keyCode, event);
	}
}