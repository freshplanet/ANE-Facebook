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
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;

public class DialogActivity extends Activity implements DialogListener
{
	private String callback;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext context = AirFacebookExtension.context;
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(context.getResourceId("layout.fb_main"));
		
		// Retrieve extra values
		Bundle extras = this.getIntent().getExtras();
		String method = extras.getString("method");
		Bundle parameters = extras.getBundle("parameters");
		callback = extras.getString("callback");
		
		// Create Facebook dialog
		AirFacebookExtensionContext.facebook.dialog(this, method, parameters, this);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		finish();
	}

	public void onComplete(Bundle values)
	{
		FREContext context = AirFacebookExtension.context;
		
		// Trigger callback if necessary
		if (context != null && callback != null)
		{
			String postId = values.getString("post_id");
			String postMessage;
			if (postId != null)
			{
				postMessage = "{ \"params\": \""+postId+"\" }";
			}
			else
			{
				postMessage = "{ \"cancel\": true }";
			}
			
			context.dispatchStatusEventAsync(callback, postMessage);
		}
		finish();
	}

	public void onFacebookError(FacebookError e)
	{
		FREContext context = AirFacebookExtension.context;
		
		// Trigger callback if necessary
		if (context != null && callback != null)
		{
			context.dispatchStatusEventAsync(callback, "{ \"error\": \""+e.getMessage()+"\" }");
		}
		finish();
	}

	public void onError(DialogError e)
	{
		FREContext context = AirFacebookExtension.context;
		
		// Trigger callback if necessary
		if (context != null && callback != null)
		{
			context.dispatchStatusEventAsync(callback, "{ \"error\": \""+e.getMessage()+"\" }");
		}
		finish();
	}

	public void onCancel()
	{
		FREContext context = AirFacebookExtension.context;
		
		// Trigger callback if necessary
		if (context != null && callback != null)
		{
			context.dispatchStatusEventAsync(callback, "{ \"cancel\": true }");
		}
		finish();
	}
}