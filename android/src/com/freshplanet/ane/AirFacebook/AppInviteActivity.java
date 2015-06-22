package com.freshplanet.ane.AirFacebook;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.widget.AppInviteDialog;

public class AppInviteActivity extends Activity implements FacebookCallback<AppInviteDialog.Result>
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.AppInviteActivity";

	private CallbackManager callbackManager;
	private AppInviteDialog appInviteDialog;

	private String callback;
	private AppInviteContent appInviteContent;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		AirFacebookExtension.log("AppInviteActivity onCreate()");

		callback = this.getIntent().getStringExtra(extraPrefix + ".callback");
		appInviteContent = this.getIntent().getParcelableExtra(extraPrefix + ".content");

		callbackManager = CallbackManager.Factory.create();

		if (AppInviteDialog.canShow()) {

			appInviteDialog = new AppInviteDialog(this);
			appInviteDialog.registerCallback(callbackManager, this);
			appInviteDialog.show(appInviteContent);
		} else {

			AirFacebookExtension.log("ERROR - CANNOT INVITE!");
			finish();
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		callbackManager.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void onSuccess(AppInviteDialog.Result result) {
		AirFacebookExtension.log("SUCCESS! " + result.toString());
		AirFacebookExtension.context.dispatchStatusEventAsync(callback, "SUCCESS");
		finish();
	}

	@Override
	public void onCancel() {
		AirFacebookExtension.log("CANCELLED!");
		AirFacebookExtension.context.dispatchStatusEventAsync(callback, "CANCELLED");
		finish();
	}

	@Override
	public void onError(FacebookException error) {
		AirFacebookExtension.log("ERROR!" + error.getMessage());
		AirFacebookExtension.context.dispatchStatusEventAsync(callback, "ERROR");
		finish();
	}
}