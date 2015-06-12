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
import com.facebook.model.OpenGraphAction;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.Callback;
import com.facebook.widget.FacebookDialog.PendingCall;

public class ShareOGActivity extends Activity implements DialogFactory, Callback
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.ShareOGActivity";
	
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
		String actionType = this.getIntent().getStringExtra(extraPrefix+".actionType");
		String previewProperty = this.getIntent().getStringExtra(extraPrefix+".previewProperty");
		Bundle ogObjectProperties = this.getIntent().getBundleExtra(extraPrefix+".actionParams");
		
		OpenGraphAction action = OpenGraphAction.Factory.createForPost(actionType);
		for ( String key:ogObjectProperties.keySet() )
			action.setProperty(key, ogObjectProperties.get(key));
		
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
		try{
			FacebookDialog.OpenGraphActionDialogBuilder dialogBuilder = 
					new FacebookDialog.OpenGraphActionDialogBuilder( this, action, actionType, previewProperty );
			
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