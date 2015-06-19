package com.freshplanet.ane.AirFacebook;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.ShareApi;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;

public class ShareDialogActivity extends Activity implements FacebookCallback<Sharer.Result>
{
	public static String extraPrefix = "com.freshplanet.ane.AirFacebook.ShareDialogActivity";

	private CallbackManager callbackManager;
	private ShareDialog shareDialog;

	private String callback;
	private Boolean useShareApi;
	private ShareLinkContent shareLinkContent;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		AirFacebookExtension.log("ShareDialogActivity onCreate()");

		callback = this.getIntent().getStringExtra(extraPrefix + ".callback");
		useShareApi = this.getIntent().getBooleanExtra(extraPrefix + ".useShareApi", false);
		shareLinkContent = this.getIntent().getParcelableExtra(extraPrefix + ".content");

		callbackManager = CallbackManager.Factory.create();

		if(useShareApi){

			ShareApi.share(shareLinkContent, this);
		} else {

			shareDialog = new ShareDialog(this);
			shareDialog.registerCallback(callbackManager, this);

			if (shareDialog.canShow(shareLinkContent, AirFacebookExtension.context.getDefaultShareDialogMode())) {

				shareDialog.show(shareLinkContent, AirFacebookExtension.context.getDefaultShareDialogMode());
			} else {

				AirFacebookExtension.log("ERROR - CANNOT SHARE!");
				finish();
			}
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		callbackManager.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void onSuccess(Sharer.Result result) {
		AirFacebookExtension.log("SUCCESS! " + result.toString());
		AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_SUCCESS_" + callback, "{}");
		finish();
	}

	@Override
	public void onCancel() {
		AirFacebookExtension.log("CANCELLED!");
		AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_CANCELLED_" + callback, "{}");
		finish();
	}

	@Override
	public void onError(FacebookException error) {
		AirFacebookExtension.log("ERROR!" + error.getMessage());
		AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_ERROR_" + callback, "{}");
		finish();
	}
}