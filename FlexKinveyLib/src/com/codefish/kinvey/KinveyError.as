package com.codefish.kinvey
{
	public class KinveyError
	{
		public function KinveyError()
		{
		}
		public var error:String;
		public var description:String;
		public var debug:String;
		
		public function showError():String{
			
			if (error == "InvalidCredentials"){
				return "Invalid Credentials";
			}
			else{
				return description;
			}
			
		}
		
		public function get isIO():Boolean{
			return error == "IOError";
		}
	}
}