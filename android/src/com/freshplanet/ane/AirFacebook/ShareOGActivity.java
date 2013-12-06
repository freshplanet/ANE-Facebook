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

import com.adobe.fre.FREContext;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.facebook.model.OpenGraphAction;
import com.facebook.model.OpenGraphObject;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.OpenGraphActionDialogBuilder;

public class ShareOGActivity extends Activity
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.ShareOGActivity";
	
	private String callback;
	private UiLifecycleHelper uiHelper;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		
		super.onCreate(savedInstanceState);
		
		uiHelper = new UiLifecycleHelper(
				this,
				new Session.StatusCallback() {
					public void call(Session session, SessionState state, Exception exception){
						
					}
				});
	    uiHelper.onCreate(savedInstanceState);
		
		// Retrieve extra values
		String actionType = this.getIntent().getStringExtra(extraPrefix+".actionType");
		String previewProperty = this.getIntent().getStringExtra(extraPrefix+".previewProperty");
		Bundle ogObjectProperties = this.getIntent().getBundleExtra(extraPrefix+".actionParams");
		callback = this.getIntent().getStringExtra(extraPrefix+".callback");
		
		OpenGraphAction action = OpenGraphAction.Factory.createForPost(actionType);
		for ( String key:ogObjectProperties.keySet() )
			action.setProperty(key, ogObjectProperties.get(key));
		
		FacebookDialog.OpenGraphActionDialogBuilder dialogBuilder = new FacebookDialog.OpenGraphActionDialogBuilder( this, action, previewProperty );
		
		uiHelper.trackPendingDialogCall( dialogBuilder.build().present() );
		
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		
		super.onActivityResult(requestCode, resultCode, data);

	    uiHelper.onActivityResult(requestCode, resultCode, data, new FacebookDialog.Callback() {
	        @Override
	        public void onError(FacebookDialog.PendingCall pendingCall, Exception error, Bundle data) {
	    		FREContext context = AirFacebookExtension.context;
	        	context.dispatchStatusEventAsync(callback, "{ \"error\": \""+error.getMessage()+"\" }");
	        }

	        @Override
	        public void onComplete(FacebookDialog.PendingCall pendingCall, Bundle data) {
	        	FREContext context = AirFacebookExtension.context;
	        	context.dispatchStatusEventAsync(callback, "{ \"success\": \"true\" }" );
	        }
	    });
	}

}