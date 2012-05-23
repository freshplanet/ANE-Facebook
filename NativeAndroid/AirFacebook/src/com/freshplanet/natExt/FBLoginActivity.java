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

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class FBLoginActivity extends Activity implements DialogListener {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("as3fb", "create fb activity");
		super.onCreate(savedInstanceState);
		
		Bundle values = this.getIntent().getExtras();
		
		String[] permissions = values.getStringArray("permissions");
		
		
		for (int i =0; i < permissions.length; i++)
		{
			Log.d("as3fb", permissions[i]);
		}
		
		if(!FBExtensionContext.facebook.isSessionValid()) {
			FBExtensionContext.facebook.authorize(this, permissions, this);
		} else
		{
			finish();
		}
		Log.d("as2fb", "doneLogin");
	}
	
	@Override
	protected void onStart()
	{
		Log.d("as3fb", "start fb activity");
		super.onStart();
	}
    
	@Override
    protected void onRestart()
	{
		Log.d("as3fb", "restart fb activity");
		super.onRestart();
	}

	@Override
    protected void onResume(){
		Log.d("as3fb", "resume fb activity");
		super.onResume();
	}

	@Override
    protected void onPause(){
		Log.d("as3fb", "pause fb activity");
		super.onPause();
	}

	@Override
    protected void onStop(){
		Log.d("as3fb", "stop fb activity");
		super.onStop();
	}

	@Override
    protected void onDestroy(){
		Log.d("as3fb", "destroy fb activity");
		super.onDestroy();
	}
	
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d("as3fb", "on activity result");
		//super.onActivityResult(requestCode, resultCode, data);
		FBExtensionContext.facebook.authorizeCallback(requestCode, resultCode, data);
		finish();
	}

	@Override
	public void onComplete(Bundle values) {
		String access_token = FBExtensionContext.facebook.getAccessToken();
		long access_expires = FBExtensionContext.facebook.getAccessExpires();
		
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOGGED_IN", access_token+"&"+Long.toString(access_expires));

		finish();
	}

	@Override
	public void onFacebookError(FacebookError e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_FB_ERROR", e.getMessage());
		
		finish();
	}

	@Override
	public void onError(DialogError e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_ERROR", e.getMessage());
		
		finish();
	}

	@Override
	public void onCancel() {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_CANCEL", "null");
		
		finish();
	}

	
	
}
