package com.codefish.kinvey
{
	import avmplus.getQualifiedClassName;

	public class CollectionCritria
	{
		
		private var kinvey:Kinvey = Kinvey.instance;
		
		public function CollectionCritria(baseEntity:String,url:String = null,authType:int=3)
		{
			if (!url){
				this.url = "appdata/"+ kinvey.appKey + "/"+ baseEntity + "/";
			}
			else
				this.url = url;
			this.baseEntity = baseEntity;
			this.authType = authType;
		}
		
		public var baseClass:Class;
		public var baseEntity:String;
		public var resultFunction:Function;
		public var faulHandler:Function;
		public var url:String;
		public var authType:int = Kinvey.AUTH_TOKEN;
		
		public function addFilter(name:String,value:Object):CollectionCritria{
			
			var obj:Object = new Object;
			obj[name] = value;
			var jsonString:String = JSON.stringify(obj);
			addParameter("query",jsonString);
			return new CollectionCritria(baseEntity,url,authType);
		}
		
		public function addResultHandler(resultFunction:Function):CollectionCritria{
			var coll:CollectionCritria = new CollectionCritria(baseEntity,url,authType);
			coll.resultFunction = resultFunction;
			coll.faulHandler = faulHandler;
			return coll;
		}
		
		public function addFaultHandler(faulHandler:Function):CollectionCritria{
			var coll:CollectionCritria = new CollectionCritria(baseEntity,url,authType);
			coll.resultFunction = resultFunction;
			coll.faulHandler = faulHandler;
			return coll;
		}
		
		public function resolve(entity:String):CollectionCritria{
			addParameter("resolve",entity);
			return new CollectionCritria(baseEntity,url,authType);
		}
		
		public function resolveAll(depth:String):CollectionCritria{
			addParameter("resolve_depth",depth);
			return new CollectionCritria(baseEntity,url,authType);
		}
		
		
		private function addParameter(param:String,value:String):void{
			if  (url.indexOf("?")>-1){
				url+="&";
			}
			else{
				url+="?";
			}
			url+=param+"="+value
		}
		
		public function list():void{
			Kinvey.instance.loadCollection(this,authType);
		}
		
	}
}