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
import com.facebook.android.Facebook.ServiceListener;
import com.facebook.android.FacebookError;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class ExtendAccessTokenActivity extends Activity implements ServiceListener, DialogListener {

	private static String TAG = "as3fb";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d(TAG, "create access activity");
		super.onCreate(savedInstanceState);
		
		Log.d(TAG, "extend access token if needed");
		
		
		boolean res = false;
		
		if (!FBExtensionContext.facebook.isSessionValid())
		{
			res = true;
			FBExtensionContext.facebook.authorize(this, this);
		}
		else if (FBExtensionContext.facebook.shouldExtendAccessToken())
		{
			res = FBExtensionContext.facebook.extendAccessTokenIfNeeded( this, this );
		}
		
		Log.d(TAG, "res : "+Boolean.toString(res));
		
		if (!res)
		{
			this.finish();
			FBExtension.context.dispatchStatusEventAsync("USER_LOGGED_IN", FBExtensionContext.facebook.getAccessToken()+'&'+Long.toString(FBExtensionContext.facebook.getAccessExpires()));
		}
		Log.d(TAG, "doneLogin");
	}
	
	@Override
	protected void onStart()
	{
		Log.d(TAG, "start access activity");
		super.onStart();
	}
    
	@Override
    protected void onRestart()
	{
		Log.d(TAG, "restart access activity");
		super.onRestart();
	}

	@Override
    protected void onResume(){
		Log.d(TAG, "resume access activity");
		super.onResume();
	}

	@Override
    protected void onPause(){
		Log.d(TAG, "pause access activity");
		super.onPause();
	}

	@Override
    protected void onStop(){
		Log.d(TAG, "stop access activity");
		super.onStop();
	}

	@Override
    protected void onDestroy(){
		Log.d(TAG, "destroy access activity");
		super.onDestroy();
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d(TAG, "on activity result");
		FBExtensionContext.facebook.authorizeCallback(requestCode, resultCode, data);
		
		finish();
	}

	@Override
	public void onComplete(Bundle values) {
		String access_token = FBExtensionContext.facebook.getAccessToken();
		long access_expires = FBExtensionContext.facebook.getAccessExpires();
		
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("ACCESS_TOKEN_REFRESHED", access_token+"&"+Long.toString(access_expires));
		
		finish();
	}

	@Override
	public void onFacebookError(FacebookError e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("ACCESS_TOKEN_FACEBOOK_ERROR", "success");
		
		finish();
	}

	@Override
	public void onError(Error e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("ACCESS_TOKEN_ERROR", "success");
		
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
