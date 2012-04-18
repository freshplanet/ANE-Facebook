package com.freshplanet.natExt;

import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class FBDialogActivity extends Activity implements DialogListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("as3fb", "create fb activity");
		super.onCreate(savedInstanceState);
		
		Bundle values = this.getIntent().getExtras();
		
		String method = values.getString("method");
		String message = values.getString("message");
		String to = values.getString("to");
		
		
		Bundle parameters = new Bundle();
		parameters.putString("message", message);
		parameters.putString("frictionless","1");
		if (to != null && to.length() > 0)
		{
			parameters.putString("to", to);
		}

		FBExtensionContext.facebook.dialog(this, method, parameters, this);

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
		finish();
	}

	@Override
	public void onComplete(Bundle values) {
		// TODO Auto-generated method stub
		finish();
	}

	@Override
	public void onFacebookError(FacebookError e) {
		// TODO Auto-generated method stub
		finish();
	}

	@Override
	public void onError(DialogError e) {
		// TODO Auto-generated method stub
		finish();
	}

	@Override
	public void onCancel() {
		// TODO Auto-generated method stub
		finish();
	}

	
}
