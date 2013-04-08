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
import android.view.KeyEvent;
import android.view.Window;
import java.util.ArrayList;
import java.util.Arrays;

import com.adobe.fre.FREContext;
//import com.facebook.android.DialogError;
//import com.facebook.android.Facebook.DialogListener;
//import com.facebook.android.FacebookError;
//import com.facebook.android.SessionStore;
import com.facebook.Session;
import com.facebook.SessionState;

public class LoginActivity extends Activity
{	
	private Session.StatusCallback statusCallback = new SessionStatusCallback();

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{

		AirFacebookExtension.log("INFO - LoginActivity.onCreate");

        int id = getResources().getIdentifier("com_facebook_login_activity_progress_bar", "id", getApplicationContext().getPackageName());
		AirFacebookExtension.log("INFO - LoginActivity.onCreate, com_facebook_login_activity_progress_bar="+id);

		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext context = AirFacebookExtension.context;
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(context.getResourceId("layout.fb_main"));
		
		// Get extra values
		Bundle extras = this.getIntent().getExtras();
		ArrayList<String> permissions = new ArrayList(Arrays.asList(extras.getStringArray("permissions")));

		Boolean forceAuthorize = extras.getBoolean("forceAuthorize", false);
		
    	AirFacebookExtension.log("INFO - LoginActivity.onCreate, test 1");
		// Authorize Facebook session if necessary
		if(forceAuthorize || !AirFacebookExtensionContext.session.isOpened())
		{
	    	AirFacebookExtension.log("INFO - LoginActivity.onCreate, test 2");
			AirFacebookExtensionContext.session.openForRead(new Session.OpenRequest(this)
				.setPermissions(permissions)
				.setCallback(statusCallback));
	    	AirFacebookExtension.log("INFO - LoginActivity.onCreate, test 3");
		}
		else
		{
			    	AirFacebookExtension.log("INFO - LoginActivity.onCreate, test 4");

			finish();
		}
		    	AirFacebookExtension.log("INFO - LoginActivity.onCreate, test 5");

	}
	
	@Override
    public void onStart() {
    	AirFacebookExtension.log("INFO - LoginActivity.onStart");
        super.onStart();
        AirFacebookExtensionContext.session.addCallback(statusCallback);
    	AirFacebookExtension.log("INFO - LoginActivity.onStart - ok");
    }

    @Override
    public void onStop() {
    	AirFacebookExtension.log("INFO - LoginActivity.onStop");
        super.onStop();
        AirFacebookExtensionContext.session.removeCallback(statusCallback);
    	AirFacebookExtension.log("INFO - LoginActivity.onStop - ok");
    }

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
    	AirFacebookExtension.log("INFO - LoginActivity.onActivityResult");
        super.onActivityResult(requestCode, resultCode, data);
        AirFacebookExtensionContext.session.onActivityResult(this, requestCode, resultCode, data);
    	AirFacebookExtension.log("INFO - LoginActivity.onActivityResult - ok");
	}
	
    @Override
    protected void onSaveInstanceState(Bundle outState) {
    	AirFacebookExtension.log("INFO - LoginActivity.onSaveInstanceState");
        super.onSaveInstanceState(outState);
        Session session = AirFacebookExtensionContext.session;
        Session.saveSession(session, outState);
    	AirFacebookExtension.log("INFO - LoginActivity.onSaveInstanceState - ok");
    }

    @Override
	public boolean onKeyUp(int keyCode, KeyEvent event)
	{
    	AirFacebookExtension.log("INFO - LoginActivity.onKeyUp");
	    if (keyCode == KeyEvent.KEYCODE_BACK)
	    {
	    	onBackPressed();
	    	AirFacebookExtension.log("INFO - LoginActivity.onKeyUp - ok");
	        return true;
	    }
	    
    	AirFacebookExtension.log("INFO - LoginActivity.onKeyUp - ok");
	    return super.onKeyUp(keyCode, event);
	}
	
	@Override
	public void onBackPressed()
	{
    	AirFacebookExtension.log("INFO - LoginActivity.onBackPressed");
		onCancel();
    	AirFacebookExtension.log("INFO - LoginActivity.onBackPressed - ok");
	}
/*
	public void onComplete(Bundle values)
	{
		//SessionStore.save(AirFacebookExtensionContext.facebook, AirFacebookExtension.context.getActivity().getApplicationContext());
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
		finish();
	}

	public void onFacebookError(FacebookError e)
	{
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", e.getMessage());	
		finish();
	}

	public void onError(DialogError e) 
	{
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", e.getMessage());	
		finish();
	}

	*/

	public void onCancel()
	{
    	AirFacebookExtension.log("INFO - LoginActivity.onCancel");

		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_CANCEL", "OK");
		finish();
    	AirFacebookExtension.log("INFO - LoginActivity.onCancel - ok");
	}

	private class SessionStatusCallback implements Session.StatusCallback {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
    		AirFacebookExtension.log("INFO - SessionStatusCallback, state = " + state);
			AirFacebookExtension.log("INFO - SessionStatusCallback, test 1");
            if (session.isOpened()) {
				AirFacebookExtension.log("INFO - SessionStatusCallback, test 2");
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
				finish();
				AirFacebookExtension.log("INFO - SessionStatusCallback, test 3");
            } else if (session.isClosed()) {
				AirFacebookExtension.log("INFO - SessionStatusCallback, test 4");
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", exception.getMessage());	
				finish();
				AirFacebookExtension.log("INFO - SessionStatusCallback, test 5");
            }
			//finish();
			AirFacebookExtension.log("INFO - SessionStatusCallback - ok");

        }
    }
}