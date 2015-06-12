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

import com.facebook.Session;
import com.facebook.android.BuildConfig;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.Callback;
import com.facebook.widget.FacebookDialog.PendingCall;

public class ShareDialogActivity extends Activity implements DialogFactory, Callback
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.ShareDialogActivity";
	
	private String callback;
	private DialogLifecycleHelper dialogHelper;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		
		super.onCreate(savedInstanceState);
		
		dialogHelper = new DialogLifecycleHelper(this, this, this);
		
		callback = this.getIntent().getStringExtra(extraPrefix+".callback");
		
		dialogHelper.onCreate(savedInstanceState);
		
	}
	
	@Override
	public PendingCall createDialog() {
		
		// Retrieve extra values
		String link = this.getIntent().getStringExtra(extraPrefix+".link");
		String name = this.getIntent().getStringExtra(extraPrefix+".name");
		String caption = this.getIntent().getStringExtra(extraPrefix+".caption");
		String description = this.getIntent().getStringExtra(extraPrefix+".description");
		String pictureUrl = this.getIntent().getStringExtra(extraPrefix+".pictureUrl");
		
		String appId;
		Session session = AirFacebookExtension.context.getSession();
		if ( session == null )
		{
			AirFacebookExtension.log("ERROR - AirFacebook is not initialized");
			finish();
			return null;
		}
		appId = session.getApplicationId();
		
		// This constructor has been modified from the original SDK
		FacebookDialog.ShareDialogBuilder dialogBuilder = new FacebookDialog.ShareDialogBuilder( this );
		if(link!=null) dialogBuilder.setLink(link);
		if(name!=null) dialogBuilder.setName(name);
		if(caption!=null) dialogBuilder.setCaption(caption);
		if(description!=null) dialogBuilder.setDescription(description);
		if(pictureUrl!=null) dialogBuilder.setPicture(pictureUrl);
		
		try{
			return dialogBuilder.build().present();
		} catch(Exception e) {
			if(BuildConfig.DEBUG) e.printStackTrace();
			AirFacebookExtension.context.dispatchStatusEventAsync(callback, AirFacebookError.makeJsonError(e));
			finish();
			return null;
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		dialogHelper.onActivityResult(requestCode, resultCode, data);
	}
	
	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
		super.onSaveInstanceState(savedInstanceState);
		dialogHelper.onSaveInstanceState(savedInstanceState);
	}
	
	@Override
	public void onComplete(PendingCall pendingCall, Bundle data) {
		AirFacebookExtension.context.dispatchStatusEventAsync(callback, "{ \"success\": \"true\" }" );
		finish();
	}

	@Override
	public void onError(PendingCall pendingCall, Exception error, Bundle data) {
		if(BuildConfig.DEBUG) error.printStackTrace();
		AirFacebookExtension.context.dispatchStatusEventAsync(callback, AirFacebookError.makeJsonError(error));
		finish();
	}

}