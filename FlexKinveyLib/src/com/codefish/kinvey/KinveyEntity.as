package com.codefish.kinvey
{

	public class KinveyEntity
	{
		
		[Transient]
		public var entity:Object;
		[Transient]
		public var baseEntity:String;
		[Transient]
		public var valueChanged:Boolean;
		
		public function KinveyEntity()
		{
		}
		public function get id():String{
			if (entity){
				return entity._id;
			}
			return null;
		}
		public function set id(id_:String):void{
			if (!entity){
				entity = {};
			}
			entity._id = id_;
		}
		
		[Transient]
		public var isReference:Boolean;
		[Transient]
		public var isNew:Boolean;
		
		public function get kinveyRef():Object{
			return {_id:id,_collection:baseEntity,_type:"KinveyRef"};
		}
		
	}
}