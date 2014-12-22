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

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import com.adobe.fre.FREContext;
import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.Session;
import com.facebook.widget.WebDialog;

public class WebDialogActivity extends Activity implements WebDialog.OnCompleteListener
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.WebDialogActivity";
	
	private String callback;
	private String method;
	
	private WebDialog dialog = null;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		AirFacebookExtension.log("WebDialogActivity.onCreate");
		super.onCreate(savedInstanceState);
		
		// Retrieve extra values
		method = this.getIntent().getStringExtra(extraPrefix+".method");
		Bundle parameters = this.getIntent().getBundleExtra(extraPrefix+".parameters");
		callback = this.getIntent().getStringExtra(extraPrefix+".callback");
		
		Session session = AirFacebookExtension.context.getSession();
		if ( session == null )
		{
			AirFacebookExtension.context.dispatchStatusEventAsync(callback, AirFacebookError.makeJsonError(AirFacebookError.NOT_INITIALIZED));
			AirFacebookExtension.log("ERROR - AirFacebook is not initialized");
			finish();
			return;
		}
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(AirFacebookExtension.getResourceId("layout.com_facebook_login_activity_layout"));
		
		if ( session.isOpened() )
		{
			dialog = new WebDialog.Builder(this, AirFacebookExtension.context.getSession(), method, parameters)
				.setOnCompleteListener(this)
				.build();
		}
		else
		{
			dialog = new WebDialog.Builder(this, session.getApplicationId(), method, parameters)
				.setOnCompleteListener(this)
				.build();
		}
		
		Window dialog_window = dialog.getWindow();
    	dialog_window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    	dialog.show();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		AirFacebookExtension.log("DialogActivity.onActivityResult");
		finish();
	}

	public void onComplete(Bundle values, FacebookException error)
	{
		FREContext context = AirFacebookExtension.context;
		AirFacebookExtension.log("INFO - DialogActivity.onComplete");

		
		// Trigger callback if necessary
		if (context != null && callback != null)
		{
			// error and not cancelled error
			if (error != null && !(error.getMessage() == null || error instanceof FacebookOperationCanceledException)) {
					AirFacebookExtension.log("DialogActivity.onComplete, error " + error.getMessage());
					context.dispatchStatusEventAsync(callback, AirFacebookError.makeJsonError(error.getMessage()));
					finish();
					return;

			}

			String postMessage = null;
			if (error == null)
			{
				// Content depends on type of dialog that was invoked (method)
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
			}
			
			// If  message wasn't set by here, then we cancelled
			if(postMessage == null)
				postMessage = "{ \"cancel\": true }";
			
			AirFacebookExtension.log("DialogActivity.onComplete, postMessage " + postMessage);
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
				ex.printStackTrace();
			}
		}
		
		return sb.toString();
	}

}
