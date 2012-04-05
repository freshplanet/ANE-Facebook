package com.freshplanet.natExt.functions;

import java.io.IOException;
import java.net.MalformedURLException;

import android.os.Bundle;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.natExt.FBExtensionContext;

public class RequestWithGraphPathFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String callbackName = null;
		try {
			callbackName = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		String graphPath = null;
		try {
			graphPath = arg1[1].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		String params = null;
		try {
			if (arg1[2] != null)
			{
				params = arg1[2].getAsString();
			}
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		
		
		String data = null;
		try {
			if (params != null)
			{
				Bundle bundle = new Bundle();
				bundle.putString("fields", params);
				
				data = FBExtensionContext.facebook.request(graphPath, bundle);

			} else
			{
				data = FBExtensionContext.facebook.request(graphPath);
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync(callbackName, e.getMessage());
		} catch (IOException e) {
			e.printStackTrace();
			arg0.dispatchStatusEventAsync(callbackName, e.getMessage());
		} catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync(callbackName, e.getMessage());
		}
		
		if (data != null)
		{
			arg0.dispatchStatusEventAsync(callbackName, data);
		}
		
		return null;
	}

}
