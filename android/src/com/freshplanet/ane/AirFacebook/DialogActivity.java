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

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Set;

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
	private String method;
	
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
		method = extras.getString("method");
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
			// Content depends on type of dialog that was invoked (method)
			String postMessage = null;
			if(method.equalsIgnoreCase("feed"))
			{
				// Check if feed gave us a post_id back, if not we cancelled
				String postId = values.getString("post_id");
				if (postId != null)
				{
					postMessage = "{ \"params\": \""+postId+"\" }";
				}
			}
			else if(method.equalsIgnoreCase("apprequests"))
			{
				// We get a request id, and a list of recepients if selected
				String request = values.getString("request");
				if (request != null)
				{
					// Give everything as URL encoded value to match iOS response
					postMessage = "{ \"params\": \"" + bundleSetToURLEncoded(values) + "\" }";
				}
			}
			
			// If  message wasn't set by here, then we cancelled
			if(postMessage == null)
				postMessage = "{ \"cancel\": true }";
			
			context.dispatchStatusEventAsync(callback, postMessage);
		}
		
		finish();
	}
	
	protected String bundleSetToURLEncoded(Bundle values)
	{
		StringBuilder sb = new StringBuilder();
		
		// Go through each key
		String[] keys = values.keySet().toArray(new String[0]);
		for (int i = 0; i < keys.length; i++) 
		{
			if(i > 0)
				sb.append("&");
			try
			{
				sb.append(keys[i]).append("=").append(URLEncoder.encode(values.get(keys[i]).toString(), "utf-8"));
			}
			catch(UnsupportedEncodingException ex)
			{
				// Um. No.
			}
		}
		
		return sb.toString();
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