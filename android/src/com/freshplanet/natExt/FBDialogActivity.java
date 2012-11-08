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
import android.util.Log;
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;

public class FBDialogActivity extends Activity implements DialogListener {

	private static String TAG = "as3fb";

	private String callbackName;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d(TAG, "create fb activity");
		super.onCreate(savedInstanceState);
		
		FREContext freContext = FBExtension.context;
		
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(freContext.getResourceId("layout.fb_main"));
		
		Bundle values = this.getIntent().getExtras();
		
		String method = values.getString("method");
		String message = values.getString("message");
		String to = values.getString("to");
		String name = values.getString("name");
		String picture = values.getString("picture");
		String link = values.getString("link");
		String caption = values.getString("caption");
		String description = values.getString("description");
		Boolean isFrictionless = values.getBoolean("frictionless", true);
		callbackName = values.getString("callback");
		
		Bundle parameters = new Bundle();
		parameters.putString("message", message);
		
		if (isFrictionless)
		{
			parameters.putString("frictionless","1");
		}
		if (to != null && to.length() > 0)
		{
			parameters.putString("to", to);
		}

		if (name != null)
		{
			parameters.putString("name", name);
		}
		if (picture != null)
		{
			parameters.putString("picture", picture);
		}
		if (link != null)
		{
			parameters.putString("link", link);
		}
		if (caption != null)
		{
			parameters.putString("caption", caption);
		}
		if (description != null)
		{
			parameters.putString("description", description);
		}
		
		FBExtensionContext.facebook.dialog(this, method, parameters, this);

	}
	
	@Override
	protected void onStart()
	{
		Log.d(TAG, "start fb activity");
		super.onStart();
	}
    
	@Override
    protected void onRestart()
	{
		Log.d(TAG, "restart fb activity");
		super.onRestart();
	}

	@Override
    protected void onResume(){
		Log.d(TAG, "resume fb activity");
		super.onResume();
	}

	@Override
    protected void onPause(){
		Log.d(TAG, "pause fb activity");
		super.onPause();
	}

	@Override
    protected void onStop(){
		Log.d(TAG, "stop fb activity");
		super.onStop();
	}

	@Override
    protected void onDestroy(){
		Log.d(TAG, "destroy fb activity");
		super.onDestroy();
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "on activity result");
		finish();
	}

	@Override
	public void onComplete(Bundle values) {
		FREContext ctx = FBExtension.context;
		if (ctx != null && callbackName != null)
		{
			String postId = values.getString("post_id");
			String postMessage = "{ \"cancel\" : true }";
			if (postId != null)
			{
				postMessage = "{ \"params\" : \""+postId+"\" }";
			}
			ctx.dispatchStatusEventAsync(callbackName, postMessage);
		}
		finish();
	}

	@Override
	public void onFacebookError(FacebookError e) {
		FREContext ctx = FBExtension.context;
		if (ctx != null && callbackName != null)
		{
			ctx.dispatchStatusEventAsync(callbackName, "{ \"error\" : \""+e.getMessage()+"\" }");
		}
		finish();
	}

	@Override
	public void onError(DialogError e) {
		FREContext ctx = FBExtension.context;
		if (ctx != null && callbackName != null)
		{
			ctx.dispatchStatusEventAsync(callbackName, "{ \"error\" : \""+e.getMessage()+"\" }");
		}

		finish();
	}

	@Override
	public void onCancel() {
		FREContext ctx = FBExtension.context;
		if (ctx != null && callbackName != null)
		{
			ctx.dispatchStatusEventAsync(callbackName, "{ \"cancel\" : true }");
		}
		finish();
	}

	
}
