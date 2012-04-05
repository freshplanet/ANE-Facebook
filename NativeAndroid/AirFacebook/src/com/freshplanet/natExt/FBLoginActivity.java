package com.freshplanet.natExt;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class FBLoginActivity extends Activity {
	
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
			FBExtensionContext.facebook.authorize(this, permissions, new FBLoginDialogListener());

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

	
	
}
