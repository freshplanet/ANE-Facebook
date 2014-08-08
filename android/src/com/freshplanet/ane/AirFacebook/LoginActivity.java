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
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import android.view.Window;

import com.facebook.FacebookOperationCanceledException;
import com.facebook.Session;
import com.facebook.SessionState;

public class LoginActivity extends Activity
{	
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.LoginActivity";
	
	private Session.StatusCallback _statusCallback = new SessionStatusCallback();
	
	private AirFacebookExtensionContext _context = null;
	
	private List<String> _permissions = null;
	private boolean _reauthorize = false;
	private Handler delayHandler;

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
		
		// Get extra values
		Bundle extras = this.getIntent().getExtras();
		_permissions = new ArrayList<String>(Arrays.asList(extras.getStringArray(extraPrefix+".permissions")));
		String type = extras.getString(extraPrefix+".type");
		_reauthorize = extras.getBoolean(extraPrefix+".reauthorize", false);
		
		// Open or reauthorize session if necessary
		Session session = _context.getSession();
		if (_reauthorize && !session.getPermissions().containsAll(_permissions))
		{
			Session.NewPermissionsRequest newPermissionsRequest = new Session.NewPermissionsRequest(this, _permissions).setCallback(_statusCallback);
			try
			{
				if ("read".equals(type))
				{
					session.requestNewReadPermissions(newPermissionsRequest);
				}
				else
				{
					session.requestNewPublishPermissions(newPermissionsRequest);
				}
			}
			catch (Exception e)
			{
				finishLogin(e);
				return;
			}
		}
		else if (!session.isOpened())
		{
			Session.OpenRequest openRequest = new Session.OpenRequest(this).setPermissions(_permissions).setCallback(_statusCallback);
			final Session finalSession = session;
			final Session.OpenRequest finalOpenRequest = openRequest;
			if (!session.getState().equals(SessionState.CREATED) && !session.getState().equals(SessionState.CREATED_TOKEN_LOADED))
			{
				_context.closeSessionAndClearTokenInformation();
				session = _context.getSession();
			}
			if(_context.usingStage3D) {
				try
				{
					delayHandler = new Handler();
					if ("read".equals(type))
					{
						delayHandler.postDelayed( new Runnable() {
	                        @Override
	                        public void run() {
	                        	try {
	                        		finalSession.openForRead(finalOpenRequest);
	                        	} catch (Exception e) {
	                        		finishLogin(e);
	                        	}
	                        }
						}, 1 );
					}
					else
					{
						delayHandler.postDelayed( new Runnable() {
	                        @Override
	                        public void run() {
	                        	try {
	                        		finalSession.openForPublish(finalOpenRequest);
	                        	} catch (Exception e) {
	                        		finishLogin(e);
	                        	}
	                        }
						}, 1 );
					}
				}
				catch (Exception e)
				{
					finishLogin(e);
					return;
				} 
			} else {
				try {
					if("read".equals(type)) 
					{
						finalSession.openForRead(finalOpenRequest);
					}
					else 
					{
						finalSession.openForPublish(finalOpenRequest);
					}
				} catch (Exception e) {
					finishLogin(e);
				}
			}
		}
		else
		{
			finishLogin();
		}
	}

	@Override
    public void onStart()
	{
        super.onStart();
        
        if (_context != null)
        {
        	_context.getSession().addCallback(_statusCallback);
        }
    }

    @Override
    public void onStop()
    {
        super.onStop();
        
        if (_context != null)
        {
        	_context.getSession().removeCallback(_statusCallback);
        }
    }

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
        super.onActivityResult(requestCode, resultCode, data);
        
        if (_context != null)
        {
        	_context.getSession().onActivityResult(this, requestCode, resultCode, data);
        }
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
		finishLogin(new FacebookOperationCanceledException());
	}

	private class SessionStatusCallback implements Session.StatusCallback
	{
        @Override
        public void call(Session session, SessionState state, Exception exception)
        {
        	if (_reauthorize || session.isOpened() || exception != null)
        	{
        		finishLogin(exception);
        	}
        }
    }
	
	private void finishLogin(Exception exception)
	{
		if (exception != null)
		{
			exception.printStackTrace();
		}
		
		if (_context == null)
    	{
    		AirFacebookExtension.log("Extension context is null");
			finish();
			return;
    	}
		
		Session session = _context.getSession();
		Boolean isCancel = (exception instanceof FacebookOperationCanceledException);
		
		String eventName = null;
		if (_reauthorize)
		{
			if (session.getPermissions().containsAll(_permissions))
			{
				eventName = "REAUTHORIZE_SESSION_SUCCESS";
			}
			else if (exception != null && !isCancel)
			{
				eventName = "REAUTHORIZE_SESSION_ERROR";
			}
			else
			{
				eventName = "REAUTHORIZE_SESSION_CANCEL";
			}
		}
		else
		{
			if (session.isOpened())
			{
				eventName = "OPEN_SESSION_SUCCESS";
			}
			else if (isCancel)
			{
				eventName = "OPEN_SESSION_CANCEL";
			}
			else if (exception != null)
			{
				eventName = "OPEN_SESSION_ERROR";
			}
		}
		
		String eventInfo = "OK";
		if (exception != null)
		{
			exception.printStackTrace();
			
			if (exception.getMessage() != null)
			{
				eventInfo = exception.getMessage();
			}
		}
		
		if (eventName != null && eventInfo != null)
		{
			_context.dispatchStatusEventAsync(eventName, eventInfo);
		}
		
		finish();
	}
	
	private void finishLogin()
	{
		finishLogin(null);
	}
}
