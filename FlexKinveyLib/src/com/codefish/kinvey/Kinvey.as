package com.codefish.kinvey
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	public class Kinvey
	{	
		public var baseUrl:String = "https://baas.kinvey.com/";
		
		public var appKey:String;

		public var publicUser:String = "";
		public var publicPassword:String = "";
		
		public const SEP:String = "/";
		
		private static var _instance:Kinvey = new Kinvey;
		
		public var username:String;
		public var password:String;
		
		[Bindable]
		public var currentUser:KinveyUser;
		
		private var appSecret:String;
		
		private var MIME_TYPE:String =  "application/json"		
		public const kinveyHelper:KinveyHelper = new KinveyHelper;
		
		public static const AUTH_BASIC:int = 1;
		public static const AUTH_APPLICATION:int = 2;
		public static const AUTH_TOKEN:int = 3;
		public static const AUTH_PUBLIC:int = 4;
		
		public static const METHOD_DELETE:String = "DELETE";
		public static const METHOD_GET:String = "GET";
		public static const METHOD_POST:String = "POST";
		public static const METHOD_PUT:String = "PUT";
		
		public var defaultFaultHandler:Function;
		
		public function initialize(appKey:String, appSecret:String, publicUser:String, publicPassword:String, kinveyBeans:Array,defaultFaultHandler:Function):void{
		
			this.defaultFaultHandler = defaultFaultHandler;
			this.appKey = appKey;
			this.appSecret = appSecret;
			this.publicPassword = publicPassword;
			this.publicUser = publicUser
			kinveyHelper.initialize(kinveyBeans);
			
		}
		
		public static function get instance():Kinvey{
			return _instance;
		}
		
		public function signUp(userName:String, password:String, fullName:String,resultFunction:Function,faultFunction:Function):void{
			var name:Array = fullName.split(" ");
			var firstName:String = "";
			var lastName:String = "";
			if (name.length>0){
				firstName = name[0];
			}
			if (name.length>1){
				lastName = name[1];
			}
				
			
			var url:String = "user/"+appKey+"/";
			createUrlRequest(url,"KinveyUser",{username:userName,password:password,email:userName, first_name:firstName, last_name:lastName},AUTH_APPLICATION,METHOD_POST,resultFunction,faultFunction);
		}
		
		public function login(username:String,password:String,resultFunction:Function,faultFunction:Function=null):void{
			
			var url:String = "user" + SEP + appKey + SEP + "login";
			this.username = username;
			this.password = password;
			
			createUrlRequest(url,"KinveyUser",{username:username,password:password},AUTH_BASIC,METHOD_POST,kinveyHelper.partial(userLogedIn,resultFunction),faultFunction);
		}
		
		public function saveEntity(entity:KinveyEntity,saveHandler:Function):void{
			
			kinveyHelper.prepareForSave(entity);
			
			if (entity.valueChanged){
				
				var mehtodType:String = METHOD_PUT;
				if (!entity.id){
					mehtodType = METHOD_POST;
				}
				
				var url:String = "appdata/"+appKey+"/"+entity.baseEntity+"/";
				
				if (entity.id)
					url+=entity.id;
				
				createUrlRequest(url,entity.baseEntity, entity.entity,AUTH_BASIC,mehtodType,saveHandler);
				entity.valueChanged = false;
			}
			
		}
		
		public function uploadFile(file:KinveyFile, uploadCompleteHandler:Function,faultHandler:Function):void{
			
			if (!file.data){
				return;
			}
			
			var url:String = "blob/"+appKey;
			
			var header:Array = [{key:"X-Kinvey-Content-Type", value:file.mimeType}];
			
			createUrlRequest(url,null, {size:file.data.length, _filename:file.fileName,mimeType:file.mimeType},AUTH_BASIC,METHOD_POST,kinveyHelper.partial(uploadFileHandler,file,uploadCompleteHandler,faultHandler),null,header);
			
		}
		
		public function uploadFileHandler(file:KinveyFile, uploadCompleteHandler:Function,faultHandler:Function,uploadObject:Object):void{
			
			var uploadURL:String = uploadObject._uploadURL;
			
			file.id = uploadObject._id;
			file.fileName = uploadObject._filename;
			
			var loader:URLLoader = new URLLoader();  
			loader.addEventListener(Event.COMPLETE, kinveyHelper.partial(fileUploadComplete,uploadCompleteHandler,file)); 
			loader.addEventListener(IOErrorEvent.IO_ERROR, kinveyHelper.partial(errorHandler,faultHandler));  
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, kinveyHelper.partial(errorHandler,faultHandler));  
			
			var request:URLRequest = new URLRequest(uploadURL);  
			request.method = URLRequestMethod.PUT;  
			
			request.requestHeaders.push(new URLRequestHeader("Content-Length", file.data.length.toString()));
			
			request.contentType = file.mimeType;       
			request.data = file.data;
			
			try {  
				loader.load(request);  
			} catch (error : Error) {  
				trace('request failed: ' + error.message);  
			}  
			
		}
		
		
		private function fileUploadComplete(completeFunction:Function,kinveyFile:KinveyFile, event:Event):void{
			
			completeFunction(kinveyFile);
			
		}
		
		
		public function passwordReset(userName:String,resultFunction:Function):void{
			var url:String = "rpc/"+appKey+"/"+userName+"/user-password-reset-initiate";
			createUrlRequest(url,null,null,AUTH_APPLICATION,METHOD_POST,resultFunction);
		}
		public function checkUserExists(userName:String,resultFunction:Function):void{
			var url:String = "rpc/"+appKey+"/check-username-exists";
			createUrlRequest(url,null,{username:userName},AUTH_APPLICATION,METHOD_POST,kinveyHelper.partial(userExistsResult,resultFunction,userName));
		}
		public function userExistsResult(resultFunction:Function,userName:String, item:Object):void{
			if (item && item.usernameExists){
				resultFunction(true,userName);
			}
			else{
				resultFunction(false,userName);
			}
		}
		
		public function updateUser(username:String, fullName:String,callBack:Function):void{
			
			var url:String = "user/"+appKey+"/"+currentUser.id;
			var obj:Object = new Object;
			if (username!=currentUser.username || fullName!=currentUser.fullName){
				obj["username"] = username;
				obj["email"] = username;

				var split:Array = fullName.split(" ");
				obj["first_name"] = split[0];
				if (split.length > 1){
					obj["last_name"] = split[1];
				}
				
				createUrlRequest(url,"KinveUser",obj,AUTH_BASIC,METHOD_PUT,kinveyHelper.partial(updateUserHandler,callBack));
			}
			else if (callBack!=null){
				callBack(null,false);
			}
			
		}
		
		private function updateUserHandler(callBack:Function,item:Object):void
		{
			var usernamechanged:Boolean = (currentUser.username != item.username);
			
			currentUser.username = item.username;
			currentUser.firstName = item.first_name;
			currentUser.lastName = item.last_name;
			currentUser.authtoken = item._kmd.authtoken;
			
			if (callBack!=null){
				callBack(item,usernamechanged);
			}
		}		
		
		public function loadEntity(kinveyEntity:KinveyEntity,resultHandler:Function):void{
			var url:String = "appdata/"+appKey+"/"+kinveyEntity.baseEntity+"/"+kinveyEntity.id;
			createUrlRequest(url,kinveyEntity.baseEntity,null,AUTH_TOKEN,METHOD_GET,resultHandler);
		}
		public function deleteEntity(kinveyEntity:KinveyEntity,resultHandler:Function):void{
			var url:String = "appdata/"+appKey+"/"+kinveyEntity.baseEntity+"/"+kinveyEntity.id;
			createUrlRequest(url,kinveyEntity.baseEntity,null,AUTH_TOKEN,METHOD_DELETE,resultHandler);
		}
		
		
		public function createUrlRequest(url_:String,baseEntity:String, params:Object, authType:int,methodType:String, resultHandler:Function,faultHandler:Function=null,headers:Array=null):void{
			
			var url:String = baseUrl + url_;
			
			if (faultHandler == null){
				faultHandler = defaultFaultHandler;
			}
			
			var loader:URLLoader = new URLLoader();  
			loader.addEventListener(Event.COMPLETE, kinveyHelper.partial(completeHandler,resultHandler,baseEntity));  
			loader.addEventListener(IOErrorEvent.IO_ERROR, kinveyHelper.partial(checkInternet,errorHandler,faultHandler));  
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, kinveyHelper.partial(checkInternet,errorHandler,faultHandler));  
			
			var request:URLRequest = new URLRequest(url);  
			request.method = URLRequestMethod.POST;  
			request.contentType = MIME_TYPE;       

			trace(methodType + " "  + request.url); 
			
			var credentials:String;
			
			switch (authType){
				
				case AUTH_BASIC:
					credentials = userCredentials;
					break;
				case AUTH_APPLICATION:
					credentials = appCredentials;
					break;
				case AUTH_TOKEN:
					credentials = userToken;
					break;
				case AUTH_PUBLIC:
					credentials = publicCredentials;
					break;
			}
			
			request.requestHeaders.push(new URLRequestHeader("Authorization", credentials));

			if (headers){
				for each (var head:Object in headers){
					request.requestHeaders.push(new URLRequestHeader(head.key,head.value));
				}
			}
			
			if (!params){
				params = new Object;
			}
			
			params["_httpmethod"] = methodType;
			
			request.data = JSON.stringify(params);	
			
			try {  
				loader.load(request);  
			} catch (error : Error) {  
				trace('request failed: ' + error.message);  
			}  
			
		}
		
		protected function completeHandler(resultHandler:Function,baseEntity:String,event:Event):void
		{
			var resultObject:String = event.currentTarget.data as String;
			if (resultHandler!=null){
				if (resultObject){
					var jsonObject:Object = JSON.parse(resultObject);
					if (jsonObject){
						
						if (jsonObject is Array){
							var resultArray:Array = new Array;
							for each (var item:Object in jsonObject){
								resultArray.push(kinveyHelper.mapObject(baseEntity,item));
							}
							kinveyHelper.processFunction(resultHandler,resultArray);
						}
						else{
							var kinveyObject:Object = kinveyHelper.mapObject(baseEntity,jsonObject);
							kinveyHelper.processFunction(resultHandler,kinveyObject);
						}
						
					}
				}
				else{
					resultHandler();
				}
				
			}
		}
//		private var monitor:URLMonitor;
		public function checkInternet(errorHandler:Function,faultHandler:Function,event:Event):void{
//			monitor = new URLMonitor(new URLRequest('http://www.google.com'));
//			monitor.addEventListener(StatusEvent.STATUS, kinveyHelper.partial(announceStatus,errorHandler,faultHandler,event));
//			monitor.start();
		}
		
		protected function announceStatus(errorHandler:Function,faultHandler:Function,event:Event,e:StatusEvent):void {
			/*if (monitor.available){
				errorHandler(faultHandler,event);
			}
			else{
				var ioerr:KinveyError = new KinveyError;
				ioerr.error = "IError";
				ioerr.description = "Please check your internet connection";
				faultHandler.call(this,ioerr);
				return;
				
			}*/
		}
		
		protected function errorHandler(faultHandler:Function,event:Event):void
		{
			if (event is IOErrorEvent){
				var err:IOErrorEvent = IOErrorEvent(event);
				var ioerr:KinveyError = new KinveyError;
				ioerr.error = "IOError";
				ioerr.description = err.text;
				faultHandler.call(this,ioerr);
				return;
			}
			
			var loader:URLLoader = event.currentTarget as URLLoader;
			trace(loader.data);
			if (faultHandler!=null){
				
				if (loader.data){
					var jsonError:Object = JSON.parse(loader.data);
					var kinveyError:KinveyError = kinveyHelper.mapObject("KinveyError",jsonError) as KinveyError;
					faultHandler(kinveyError);
					return;
				}
				else{
					var noErr:KinveyError = new KinveyError;
					faultHandler(noErr);
				}
			}
		}
		
		private function userLogedIn(resultFunction:Function,user:KinveyUser):void{
			this.currentUser = user;
			
			this.currentUser.username=username;
			this.currentUser.password=password;
			
			kinveyHelper.processFunction(resultFunction,user);
		}
		
		public function loadCollection(criteria:CollectionCritria,authType:int=AUTH_TOKEN):void{
			createUrlRequest(criteria.url,criteria.baseEntity,null,authType,METHOD_GET,criteria.resultFunction,criteria.faulHandler);
		}
		
		
		/*
		private function serviceFault(event:FaultEvent,params:Array):void
		{
			trace(event.message);
			if (params && params.length >=2){
				if (params[1]){
					
					if (event.fault.content){
						var json:Object = JSON.parse(event.fault.content as String);
						var kinveyError:KinveyError = mapObject("KinveyError",json) as KinveyError;
						params[1](kinveyError);
					}
					
				}
			}
		}*/
		
		
		public function get appCredentials():String{
			return "Basic " + kinveyHelper.encode(appKey+":"+appSecret);
		}
		public function get publicCredentials():String{
			return "Basic " + kinveyHelper.encode(publicUser+":"+publicPassword);
		}
		public function get userCredentials():String{
			return "Basic " + kinveyHelper.encode(username+":"+password);
		}
		public function get userToken():String{
			return "Kinvey " + currentUser.authtoken;
		}
		
	}
}