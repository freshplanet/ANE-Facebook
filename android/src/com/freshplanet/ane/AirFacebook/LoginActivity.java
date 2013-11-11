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
import android.os.Handler;
import android.view.KeyEvent;
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.Session;
import com.facebook.SessionLoginBehavior;
import com.facebook.SessionState;

public class LoginActivity extends Activity
{	
	private Session.StatusCallback statusCallback = new SessionStatusCallback();
	private boolean reauthorize = false;
	private Handler delayHandler;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{

		AirFacebookExtension.log("INFO - LoginActivity.onCreate");

		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext context = AirFacebookExtension.context;
		if (context == null)
		{
			finish();
			return;
		}
		
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
		if (reauthorize)
		{
			try
			{
				if ("read".equals(type))
				{
					AirFacebookExtensionContext.session.requestNewReadPermissions(
						new Session.NewPermissionsRequest(this, permissions)
							.setCallback(statusCallback));
				}
				else
				{
					AirFacebookExtensionContext.session.requestNewPublishPermissions(
						new Session.NewPermissionsRequest(this, permissions)
							.setCallback(statusCallback));
				}

			}
			catch (FacebookException exception)
			{
				AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_ERROR", exception != null ? exception.toString() : "null exception");
			}
			catch (UnsupportedOperationException exception)
			{
				AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_ERROR", exception != null ? exception.toString() : "null exception");
			}
		}
		else if (!AirFacebookExtensionContext.session.isOpened())
		{
			try
			{
				delayHandler = new Handler();
				final LoginActivity me = this;
				final ArrayList<String> perms = permissions;
				
				if ("read".equals(type))
				{
					delayHandler.postDelayed( new Runnable() {
						@Override
						public void run() {
							AirFacebookExtensionContext.session.openForRead(new Session.OpenRequest(me)
							.setPermissions(perms)
							.setCallback(me.statusCallback));
						}
					}, 1 );

				}
				else if ("publish".equals(type))
				{
					delayHandler.postDelayed( new Runnable() {
						@Override
						public void run() {
							AirFacebookExtensionContext.session.openForPublish(new Session.OpenRequest(me)
							.setPermissions(perms)
							.setCallback(me.statusCallback));
						}
					}, 1 );
				}
				else
				{
					delayHandler.postDelayed( new Runnable() {
						@Override
						public void run() {
							AirFacebookExtensionContext.session.openForPublish(new Session.OpenRequest(me)
							.setPermissions(perms)
							.setCallback(me.statusCallback));
						}
					}, 1 );
					
				}

			}
			catch (FacebookException exception)
			{
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", exception != null ? exception.toString() : "null exception");
			}
			catch (UnsupportedOperationException exception)
			{
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", exception != null ? exception.toString() : "null exception");
			}
		}
		else
		{
			finish();
		}
	}

	@Override
    public void onStart()
	{
        super.onStart();
        AirFacebookExtensionContext.session.addCallback(statusCallback);
    }

    @Override
    public void onStop()
    {
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
    protected void onSaveInstanceState(Bundle outState)
    {
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
		String event = reauthorize ? "REAUTHORIZE_SESSION_CANCEL" : "OPEN_SESSION_CANCEL";
		AirFacebookExtension.context.dispatchStatusEventAsync(event, "OK");
		finish();
	}

	private class SessionStatusCallback implements Session.StatusCallback
	{
        @Override
        public void call(Session session, SessionState state, Exception exception)
        {
    		AirFacebookExtension.log("INFO - SessionStatusCallback, state = " + state);
    		
    		Boolean isCancel = (exception instanceof FacebookOperationCanceledException);
    		
			if (reauthorize)
			{
				if (state.equals(SessionState.OPENED_TOKEN_UPDATED))
				{
					AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_SUCCESS", "OK");
				}
				else if (isCancel)
				{
					AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_CANCEL", "OK");
				}
				else
				{
					String error = exception != null ? exception.toString() : "null exception";
					AirFacebookExtension.context.dispatchStatusEventAsync("REAUTHORIZE_SESSION_ERROR", error);
				}
				finish();
			}
			else if (session.isOpened()) 
			{
				AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
				finish();
            }
			else if (session.isClosed())
			{
				if (isCancel)
				{
					AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_CANCEL", "OK");
				}
				else
	            {
	            	String error = exception != null ? exception.toString() : "null exception";
					AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", error);	
	            }
	            finish();
			}
			
			AirFacebookExtension.log("INFO - SessionStatusCallback - ok");
        }
    }
}