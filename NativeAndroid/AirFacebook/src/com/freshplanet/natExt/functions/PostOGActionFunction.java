package com.freshplanet.natExt.functions;

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.natExt.FBRequestThread;

public class PostOGActionFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String graphPath = null;
		try {
			graphPath = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
			return null;
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
			return null;
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
			return null;
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
			return null;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		Bundle params = new Bundle();

		
		FREArray keyArray = (FREArray) arg1[1];
		FREArray valueArray = (FREArray) arg1[2];
		
		long arrayLength;
		try {
			arrayLength = keyArray.getLength();
			String key;
			String value;
			for (int i = 0; i < arrayLength; i++)
			{
				key =  keyArray.getObjectAt((long) i).getAsString();
				value = valueArray.getObjectAt((long) i).getAsString();
				params.putString(key, value);
			}
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		}

		
		// try it by crating a new thread.
		
		FBRequestThread thread = new FBRequestThread(arg0,"", graphPath, params, "POST");
		thread.start();
		
		return null;
	}

}
