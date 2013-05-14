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

import java.util.ArrayList;
import java.util.Arrays;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.Session;
import com.facebook.SessionLoginBehavior;
import com.facebook.SessionState;

public class LoginActivity extends Activity
{	
	private Session.StatusCallback statusCallback = new SessionStatusCallback();
	private boolean reauthorize = false;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{

		AirFacebookExtension.log("INFO - LoginActivity.onCreate");

		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext context = AirFacebookExtension.context;
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(context.getResourceId("layout.fb_main"));
		
		// Get extra values
		Bundle extras = this.getIntent().getExtras();
		ArrayList<String> permissions = new ArrayList<String>(Arrays.asList(extras.getStringArray("permissions")));
		String type = extras.getString("type");

		reauthorize = extras.getBoolean("reauthorize", false);
		
		AirFacebookExtension.log("INFO - LoginActivity.onCreate, session.isClosed " + AirFacebookExtensionContext.session.isClosed() + ", state " + AirFacebookExtensionContext.session.getState());
		
		// Authorize Facebook session if necessary
		if (reauthorize) {
			if ("read".equals(type)) {
				AirFacebookExtensionContext.session.requestNewReadPermissions(
					new Session.NewPermissionsRequest(this, permissions)
						.setCallback(statusCallback));
			} else {
				AirFacebookExtensionContext.session.requestNewPublishPermissions(
					new Session.NewPermissionsRequest(this, permissions)
						.setCallback(statusCallback));
			}
		} else if (!AirFacebookExtensionContext.session.isOpened()) {
			if ("read".equals(type)) {
				AirFacebookExtensionContext.session.openForRead(new Session.OpenRequest(this)
					.setPermissions(permissions)
					.setCallback(statusCallback));
			} else if ("publish".equals(type)) {
				AirFacebookExtensionContext.session.openForPublish(new Session.OpenRequest(this)
					.setPermissions(permissions)
					.setCallback(statusCallback));
			} else {
				AirFacebookExtensionContext.session.openForPublish(new Session.OpenRequest(this)
					.setPermissions(permissions)
					.setLoginBehavior(SessionLoginBehavior.SUPPRESS_SSO)
					.setCallback(statusCallback));
			}
		}
		else
		{
			finish();
		}

	}

	@Override
    public void onStart() {
        super.onStart();
        AirFacebookExtensionContext.session.addCallback(statusCallback);
    }

    @Override
    public void onStop() {
        super.onStop();
        AirFacebookExtensionContext.session.removeCallback(statusCallback);
    }

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
        super.onActivityResult(requestCode, resultCode, data);
        AirFacebookExtensionContext.session.onActivityResult(this, requestCode, resultCode, data);
	}
	
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Session session = AirFacebookExtensionContext.session;
        Session.saveSession(session, outState);
    }

    @Override
	public boolean onKeyUp(int keyCode, KeyEvent event)
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK)
	    {
	    	onBackPressed();
	        return true;
	    }
	    return super.onKeyUp(keyCode, event);
	}
	
	@Override
	public void onBackPressed()
	{
		onCancel();
	}

	public void onCancel()
	{
		if (reauthorize) {
			AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_CANCEL", "OK");
		} else {
			AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_CANCEL", "OK");
		}
		finish();
	}

	private class SessionStatusCallback implements Session.StatusCallback {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
    		AirFacebookExtension.log("INFO - SessionStatusCallback, state = " + state);
			if (reauthorize) {
				if (state.equals(SessionState.OPENED_TOKEN_UPDATED)) {
					AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_SUCCESS", "OK");
				} else {
					String error = exception.getMessage() != null ? exception.getMessage() : "";
					AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_ERROR", error);
				}
				finish();
			} else if (session.isOpened()) {
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
				finish();
            } else if (session.isClosed()) {
            	String error = exception.getMessage() != null ? exception.getMessage() : "";
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", error);	
				finish();
            }
			AirFacebookExtension.log("INFO - SessionStatusCallback - ok");

        }
    }

}
