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
import com.facebook.widget.FacebookDialog;

public class ShareDialogActivity extends Activity
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.ShareDialogActivity";
	
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
		String link = this.getIntent().getStringExtra(extraPrefix+".link");
		String name = this.getIntent().getStringExtra(extraPrefix+".name");
		String caption = this.getIntent().getStringExtra(extraPrefix+".caption");
		String description = this.getIntent().getStringExtra(extraPrefix+".description");
		String pictureUrl = this.getIntent().getStringExtra(extraPrefix+".pictureUrl");
		callback = this.getIntent().getStringExtra(extraPrefix+".callback");
		
		FacebookDialog.ShareDialogBuilder dialogBuilder = new FacebookDialog.ShareDialogBuilder( this );
		if(link!=null) dialogBuilder.setLink(link);
		if(name!=null) dialogBuilder.setName(name);
		if(caption!=null) dialogBuilder.setCaption(caption);
		if(description!=null) dialogBuilder.setDescription(description);
		if(pictureUrl!=null) dialogBuilder.setPicture(pictureUrl);
		
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