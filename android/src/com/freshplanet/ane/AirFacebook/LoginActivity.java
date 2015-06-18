package com.freshplanet.ane.AirFacebook;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.app.Activity;

import android.content.Intent;
import android.os.Bundle;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;

import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

public class LoginActivity extends Activity
{	
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.LoginActivity";

	private CallbackManager callbackManager;
	
	private AirFacebookExtensionContext _context = null;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		// Retrieve context
		_context = AirFacebookExtension.context;
		if (_context == null) {
			AirFacebookExtension.log("Extension context is null");
			finish();
			return;
		}

		// Get extra values
		Bundle extras = this.getIntent().getExtras();
		List<String> permissions = new ArrayList<String>(Arrays.asList(extras.getStringArray(extraPrefix+".permissions")));
		String type = extras.getString(extraPrefix+".type");

		callbackManager = CallbackManager.Factory.create();

		LoginManager.getInstance().registerCallback(callbackManager,
				new FacebookCallback<LoginResult>() {
					@Override
					public void onSuccess(LoginResult loginResult) {
						AirFacebookExtension.log("OPEN_SESSION_SUCCESS");
						_context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
						finish();
					}

					@Override
					public void onCancel() {
						AirFacebookExtension.log("OPEN_SESSION_CANCEL");
						_context.dispatchStatusEventAsync("OPEN_SESSION_CANCEL", "OK");
						finish();
					}

					@Override
					public void onError(FacebookException exception) {
						AirFacebookExtension.log("OPEN_SESSION_ERROR " + exception.toString());
						exception.printStackTrace();
						_context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", exception.getMessage());
						finish();
					}
				});

		try {
			if ("read".equals(type)) {
				LoginManager.getInstance().logInWithReadPermissions(this, permissions);
			} else {
				LoginManager.getInstance().logInWithPublishPermissions(this, permissions);
			}
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("OPEN_SESSION_ERROR " + e.toString());
			e.printStackTrace();
			_context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", e.getMessage());
			finish();
			return;
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
        super.onActivityResult(requestCode, resultCode, data);
		callbackManager.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void onBackPressed()
	{
		AirFacebookExtension.log("OPEN_SESSION_ERROR " + "BACK_BUTTON");
		_context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", "BACK_BUTTON");
		finish();
	}
}
