package com.freshplanet.ane.AirFacebook;

public class AirFacebookError {
	
	public static final String NOT_INITIALIZED = "not_initialized";
	
	public static final String makeJsonError( String error ){
		
		return "{ \"error\" : \""+ error +"\"}";
		
	}
	
	public static final String makeJsonError( Exception error ){
		
		return makeJsonError( error.getMessage() );
		
	}
	
}