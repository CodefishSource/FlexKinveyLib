package com.codefish.kinvey
{

	public class KinveyUser extends KinveyEntity
	{
		
		public function KinveyUser()
		{
		}
		
		public function get email():String
		{
			return username;
		}

		public function set firstName(name:String):void{
			entity.first_name = name;;
		}
		
		public function get firstName():String{
			return entity.first_name;
		}
		
		public function get lastName():String{
			return entity.last_name;
		}
		public function set lastName(name:String):void{
			entity.last_name = name;;
		}
		public function get fullName():String{
			return firstName + " " + lastName;
		}
		public function get authtoken():String{
			return entity._kmd.authtoken;
		}
		public function set authtoken(token:String):void{
			entity._kmd.authtoken = token;
		}
		
		public function isTokenValid():Boolean
		{
			return entity && entity._kmd.authtoken;
		}
		[Bindable]
		public var username:String;
		
		public var password:String;
		
	}
}