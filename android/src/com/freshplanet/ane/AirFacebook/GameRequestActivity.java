package com.freshplanet.ane.AirFacebook;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.widget.GameRequestDialog;

public class GameRequestActivity extends Activity implements FacebookCallback<GameRequestDialog.Result>
{
    public static String extraPrefix = "com.freshplanet.ane.AirFacebook.GameRequestActivity";

    private CallbackManager callbackManager;
    private GameRequestDialog gameRequestDialog;

    private String callback;
    private GameRequestContent gameRequestContent;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        AirFacebookExtension.log("GameRequestActivity onCreate()");

        callback = this.getIntent().getStringExtra(extraPrefix + ".callback");
        gameRequestContent = this.getIntent().getParcelableExtra(extraPrefix + ".content");

        callbackManager = CallbackManager.Factory.create();

        if (GameRequestDialog.canShow()) {

            gameRequestDialog = new GameRequestDialog(this);
            gameRequestDialog.registerCallback(callbackManager, this);
            gameRequestDialog.show(gameRequestContent);
        } else {

            AirFacebookExtension.log("ERROR - CANNOT REQUEST!");
            finish();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onSuccess(GameRequestDialog.Result result) {
        AirFacebookExtension.log("REQUEST_COMPLETE " + result.toString());

        String resultString = "{\"request\":" + result.getRequestId() + ",\"recipients\":" + result.getRequestRecipients() + "}";
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, resultString);
        finish();
    }

    @Override
    public void onCancel() {
        AirFacebookExtension.log("REQUEST_CANCEL!");
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, "OK");
                finish();
    }

    @Override
    public void onError(FacebookException error) {
        AirFacebookExtension.log("REQUEST_ERROR error: " + error.getMessage());
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, error.getMessage());
                finish();
    }
}
