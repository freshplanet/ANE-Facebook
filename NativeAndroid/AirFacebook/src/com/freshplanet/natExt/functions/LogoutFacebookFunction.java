package com.freshplanet.natExt.functions;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.AsyncFacebookRunner.RequestListener;
import com.facebook.android.FacebookError;
import com.freshplanet.natExt.FBExtensionContext;

public class LogoutFacebookFunction implements FREFunction, RequestListener {

	
	private FREContext freContext;
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		freContext = arg0;
		
		AsyncFacebookRunner mAsyncRunner = new AsyncFacebookRunner( FBExtensionContext.facebook);
		
		mAsyncRunner.logout(freContext.getActivity(), this);
		return null;
	}

	
	  @Override
	  public void onComplete(String response, Object state) {
			freContext.dispatchStatusEventAsync("USER_LOGGED_OUT", "Success");
	  }
	  
	  @Override
	  public void onIOException(IOException e, Object state) {
			freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	  }
	  
	  @Override
	  public void onFileNotFoundException(FileNotFoundException e,
	        Object state) {
			freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	  }
	  
	  @Override
	  public void onMalformedURLException(MalformedURLException e,
	        Object state) {
			freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	  }
	  
	  @Override
	  public void onFacebookError(FacebookError e, Object state) {
			freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	  }
	
}
