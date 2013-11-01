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
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import com.facebook.FacebookException;
import com.facebook.widget.WebDialog;

public class DialogActivity extends Activity implements WebDialog.OnCompleteListener
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.DialogActivity";
	
	private AirFacebookExtensionContext _context;
	
	private String _callback;
	private String _method;
	
	private WebDialog _dialog = null;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Retrieve context
		_context = AirFacebookExtension.context;
		if (_context == null)
		{
			AirFacebookExtension.log("Extension context is null");
			finish();
			return;
		}
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(_context.getResourceId("layout.com_facebook_login_activity_layout"));
		
		// Retrieve extra values
		Bundle extras = this.getIntent().getExtras();
		_method = extras.getString(extraPrefix+".method");
		Bundle parameters = extras.getBundle(extraPrefix+".parameters");
		_callback = extras.getString(extraPrefix+".callback");
		
		// Create WebDialog
		_dialog = new WebDialog.Builder(this, _context.getSession(), _method, parameters).setOnCompleteListener(this).build();
		Window dialog_window = _dialog.getWindow();
    	dialog_window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    	_dialog.show();
	}

	public void onComplete(Bundle values, FacebookException error)
	{
		if (_context == null)
    	{
    		AirFacebookExtension.log("Extension context is null");
			finish();
			return;
    	}
		
		// Trigger callback if necessary
		if (_callback != null)
		{
			if (error != null)
			{
				_context.dispatchStatusEventAsync(_callback, "{ \"error\": \""+error.getMessage()+"\" }");
				finish();
				return;
			}

			// Content depends on type of dialog that was invoked (method)
			String postMessage = null;
			if (_method.equalsIgnoreCase("feed"))
			{
				// Check if feed gave us a post_id back, if not we cancelled
				String postId = values.getString("post_id");
				if (postId != null)
				{
					postMessage = "{ \"params\": \""+postId+"\" }";
				}
			}
			else if (_method.equalsIgnoreCase("apprequests"))
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
			if (postMessage == null)
			{
				postMessage = "{ \"cancel\": true }";
			}
			
			_context.dispatchStatusEventAsync(_callback, postMessage);
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
			if (i > 0)
				sb.append("&");
			try
			{
				sb.append(keys[i]).append("=").append(URLEncoder.encode(values.get(keys[i]).toString(), "utf-8"));
			}
			catch (UnsupportedEncodingException e)
			{
				e.printStackTrace();
			}
		}
		
		return sb.toString();
	}
}