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

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Base64;
import android.view.KeyEvent;
import android.view.Window;

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;
import com.facebook.android.SessionStore;

public class LoginActivity extends Activity implements DialogListener
{	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Get context
		FREContext context = AirFacebookExtension.context;
		
		// Setup views
		requestWindowFeature(Window.FEATURE_LEFT_ICON);
		setContentView(context.getResourceId("layout.fb_main"));
		
		// Get extra values
		Bundle extras = this.getIntent().getExtras();
		String[] permissions = extras.getStringArray("permissions");
		Boolean forceAuthorize = extras.getBoolean("forceAuthorize", false);
		
		// Authorize Facebook session if necessary
		if(forceAuthorize || !AirFacebookExtensionContext.facebook.isSessionValid())
		{
			AirFacebookExtensionContext.facebook.authorize(this, permissions, this);
		}
		else
		{
			finish();
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		AirFacebookExtensionContext.facebook.authorizeCallback(requestCode, resultCode, data);
		finish();
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

	public void onComplete(Bundle values)
	{
		SessionStore.save(AirFacebookExtensionContext.facebook, AirFacebookExtension.context.getActivity().getApplicationContext());
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_SUCCESS", "OK");
		finish();
	}

	public void onFacebookError(FacebookError e)
	{
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", e.getMessage());	
		AirFacebookExtension.log("onFbError");
	    // Add code to print out the key hash
	    try {
	        PackageInfo info = getPackageManager().getPackageInfo(
	        		getApplicationContext().getPackageName(),
	                PackageManager.GET_SIGNATURES);
	        for (Signature signature : info.signatures) {
	            MessageDigest md = MessageDigest.getInstance("SHA");
	            md.update(signature.toByteArray());
	            AirFacebookExtension.log("keyHash:"+Base64.encodeToString(md.digest(), Base64.DEFAULT));
	            }
	    } catch (NameNotFoundException ex) {
	    	AirFacebookExtension.log("name not found");
	    } catch (NoSuchAlgorithmException ex) {
	    	AirFacebookExtension.log("no such algo");
	    }

		finish();
	}

	public void onError(DialogError e) 
	{
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_ERROR", e.getMessage());	
		AirFacebookExtension.log("onError");
	    // Add code to print out the key hash
	    try {
	        PackageInfo info = getPackageManager().getPackageInfo(
	                getApplicationContext().getPackageName(),
	                PackageManager.GET_SIGNATURES);
	        for (Signature signature : info.signatures) {
	            MessageDigest md = MessageDigest.getInstance("SHA");
	            md.update(signature.toByteArray());
	            AirFacebookExtension.log("keyHash:"+Base64.encodeToString(md.digest(), Base64.DEFAULT));
	            }
	    } catch (NameNotFoundException ex) {
	    	AirFacebookExtension.log("name not found");
	    } catch (NoSuchAlgorithmException ex) {
	    	AirFacebookExtension.log("no such algo");
	    }
		
		finish();
	}

	public void onCancel()
	{
		AirFacebookExtension.context.dispatchStatusEventAsync("OPEN_SESSION_CANCEL", "OK");
		finish();
	}
}