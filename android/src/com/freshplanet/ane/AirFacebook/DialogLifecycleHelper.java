package com.freshplanet.ane.AirFacebook;

import java.util.UUID;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.internal.NativeProtocol;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.PendingCall;

public class DialogLifecycleHelper {
	
	private static final String DIALOG_CALL_ID_PROPERTY = "com.freshplanet.ane.AirFacebook.DialogLifecycleHelper.DIALOG_CALL_ID";
	
	Activity activity;
	PendingCall dialogCall;
	DialogFactory dialogFactory;
	FacebookDialog.Callback onDialogReturn;
	
	public DialogLifecycleHelper(Activity activity, DialogFactory dialogFactory, FacebookDialog.Callback onDialogReturn) {
		
		this.activity = activity;
		this.dialogFactory = dialogFactory;
		this.onDialogReturn = onDialogReturn;
		
	}
	
	public void onCreate(Bundle savedInstanceState) {
		
		retreivePendingCall(savedInstanceState);
		if (dialogCall == null)
			dialogCall = dialogFactory.createDialog();
		
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		if (dialogCall == null || dialogCall.getRequestCode() != requestCode)
			return;

		if (data == null) {
            // We understand the request code, but have no Intent. This can happen if the called Activity crashes
            // before it can be started; we treat this as a cancellation because we have no other information.
			cancelDialogCall();
        }

        String callIdString = data.getStringExtra(NativeProtocol.EXTRA_PROTOCOL_CALL_ID);
        UUID callId = null;
        if (callIdString != null) {
            try {
                callId = UUID.fromString(callIdString);
            } catch (IllegalArgumentException exception) {
            }
        }

        // Was this result for the call we are waiting on?
        if (callId != null && dialogCall.getCallId().equals(callId)) {
            // Yes, we can handle it normally.
            FacebookDialog.handleActivityResult(activity, dialogCall, requestCode, data, onDialogReturn);
        } else {
            // No, send a cancellation error to the pending call and ignore the result, because we
            // don't know what to do with it.
        	cancelDialogCall();
        }

        dialogCall = null;
	}
	
	private void cancelDialogCall() {
        Intent pendingIntent = dialogCall.getRequestIntent();

        Intent cancelIntent = new Intent();
        cancelIntent.putExtra(NativeProtocol.EXTRA_PROTOCOL_CALL_ID,
                pendingIntent.getStringExtra(NativeProtocol.EXTRA_PROTOCOL_CALL_ID));
        cancelIntent.putExtra(NativeProtocol.EXTRA_PROTOCOL_ACTION,
                pendingIntent.getStringExtra(NativeProtocol.EXTRA_PROTOCOL_ACTION));
        cancelIntent.putExtra(NativeProtocol.EXTRA_PROTOCOL_VERSION,
                pendingIntent.getIntExtra(NativeProtocol.EXTRA_PROTOCOL_VERSION, 0));
        cancelIntent.putExtra(NativeProtocol.STATUS_ERROR_TYPE, NativeProtocol.ERROR_UNKNOWN_ERROR);

        FacebookDialog.handleActivityResult(activity, dialogCall,
                dialogCall.getRequestCode(), cancelIntent, onDialogReturn);
        
        dialogCall = null;
    }
	
	public void onSaveInstanceState(Bundle savedInstanceState) {
		
		savedInstanceState.putParcelable(DIALOG_CALL_ID_PROPERTY, dialogCall);
		
	}
	
	private void retreivePendingCall( Bundle savedInstanceState ) {
		
		if ( savedInstanceState == null ) return;
		dialogCall = savedInstanceState.getParcelable(DIALOG_CALL_ID_PROPERTY);
		
	}
	
}

interface DialogFactory {
	
	public PendingCall createDialog();
	
}
