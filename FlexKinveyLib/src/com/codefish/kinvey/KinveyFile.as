package com.codefish.kinvey
{
	import flash.utils.ByteArray;

	public class KinveyFile extends KinveyEntity
	{
		
		public function KinveyFile(data:ByteArray=null)
		{
			super();
			baseEntity ="KinveyFile";
			this.data = data;
			entity = new Object;
		}
		public function get downloadUrl():String{
			return entity._downloadURL;
		}
		public function get fileName():String{
			return entity._filename;
		}
		public function get mimeType():String{
			return entity.mimeType;
		}
		public function get size():Number{
			return entity.size;
		}
		
		public function set fileName(val:String):void{
			entity._filename = val;
		}
		public function set mimeType(mimeType:String):void{
			entity.mimeType = mimeType;
		}
		
		[Transient]
		public var data:ByteArray;
		
		
		override public function get kinveyRef():Object{
			return {_id:id,_type:"KinveyFile"};
		}
	}
}