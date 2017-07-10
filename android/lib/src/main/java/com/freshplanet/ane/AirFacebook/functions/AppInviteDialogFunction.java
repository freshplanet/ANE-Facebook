package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;
import com.adobe.air.AirFacebookActivityResultCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.widget.AppInviteDialog;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.utils.FREConversionUtil;

public class AppInviteDialogFunction extends BaseFunction implements AirFacebookActivityResultCallback, FacebookCallback<AppInviteDialog.Result> {

    private String callback;
    private CallbackManager callbackManager;
    AndroidActivityWrapper aaw;

    @Override
	public FREObject call(FREContext context, FREObject[] args) {

        if (!AppInviteDialog.canShow()) {

            AirFacebookExtension.log("ERROR - CANNOT INVITE!");
            return null;
        }

		String appLinkUrl = FREConversionUtil.toString(FREConversionUtil.getProperty("appLinkUrl", args[0]));
		String previewImageUrl = FREConversionUtil.toString(FREConversionUtil.getProperty("previewImageUrl", args[0]));

		callback = getStringFromFREObject(args[1]);

		AirFacebookExtension.log("AppInviteDialogFunction appLinkUrl:" + appLinkUrl + " previewImageUrl:" + previewImageUrl);

		AppInviteContent.Builder builder = new AppInviteContent.Builder();
		if (appLinkUrl != null) builder.setApplinkUrl(appLinkUrl);
		if (previewImageUrl != null) builder.setPreviewImageUrl(previewImageUrl);
		AppInviteContent appInviteContent = builder.build();

        callbackManager = CallbackManager.Factory.create();
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
        aaw.addActivityResultListener(this);

        AppInviteDialog appInviteDialog = new AppInviteDialog(aaw.getActivity());
        appInviteDialog.registerCallback(callbackManager, this);
        appInviteDialog.show(appInviteContent);

		return null;
	}

    @Override
    public void onActivityResult(int i, int i1, Intent intent) {
        callbackManager.onActivityResult(i, i1, intent);
    }

    @Override
    public void onSuccess(AppInviteDialog.Result result) {

        AirFacebookExtension.log("SUCCESS! " + result.toString());
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, "SUCCESS");
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onCancel() {

        AirFacebookExtension.log("CANCELLED!");
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, "CANCELLED");
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onError(FacebookException error) {

        AirFacebookExtension.log("ERROR!" + error.getMessage());
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, "ERROR");
        aaw.removeActivityResultListener(this);
    }
}