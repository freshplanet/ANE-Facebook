package com.freshplanet.natExt;

import com.adobe.fre.FREContext;
import com.facebook.android.Facebook.ServiceListener;
import com.facebook.android.FacebookError;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class ExtendAccessTokenActivity extends Activity implements ServiceListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("as3fb", "create access activity");
		super.onCreate(savedInstanceState);
		
		Log.d("as3fb", "extend access token if needed");
		
		
		boolean res = false;
		
		if (!FBExtensionContext.facebook.isSessionValid())
		{
			res = true;
			FBExtensionContext.facebook.authorize(this, new FBLoginDialogListener());
		}
		else if (FBExtensionContext.facebook.shouldExtendAccessToken())
		{
			res = FBExtensionContext.facebook.extendAccessTokenIfNeeded( this, this );
		}
		
		Log.d("as3fb", "res : "+Boolean.toString(res));
		
		if (!res)
		{
			this.finish();
			FBExtension.context.dispatchStatusEventAsync("USER_LOGGED_IN", FBExtensionContext.facebook.getAccessToken()+'&'+Long.toString(FBExtensionContext.facebook.getAccessExpires()));
		}
		Log.d("as2fb", "doneLogin");
	}
	
	@Override
	protected void onStart()
	{
		Log.d("as3fb", "start access activity");
		super.onStart();
	}
    
	@Override
    protected void onRestart()
	{
		Log.d("as3fb", "restart access activity");
		super.onRestart();
	}

	@Override
    protected void onResume(){
		Log.d("as3fb", "resume access activity");
		super.onResume();
	}

	@Override
    protected void onPause(){
		Log.d("as3fb", "pause access activity");
		super.onPause();
	}

	@Override
    protected void onStop(){
		Log.d("as3fb", "stop access activity");
		super.onStop();
	}

	@Override
    protected void onDestroy(){
		Log.d("as3fb", "destroy access activity");
		super.onDestroy();
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d("as3fb", "on activity result");
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

}
