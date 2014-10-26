package com.codefish.kinvey
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.utils.Base64Encoder;
	
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;

	public class KinveyHelper
	{
		public function KinveyHelper()
		{
		}
		public var dict:Dictionary = new Dictionary;
		
		public var dateUtil:ISO8602Util = new ISO8602Util;
		
		public function mapObject(baseEntity:String, kinveyObject:Object):Object{
			
			var myObject:Object = kinveyObject; 
			
			var typeDef:Type = dict[baseEntity];
			if (typeDef){
				var newInstance:Class = getDefinitionByName(typeDef.fullName) as Class;
				myObject = new newInstance();
				if (myObject is KinveyEntity){
					KinveyEntity(myObject).entity = kinveyObject;
					KinveyEntity(myObject).baseEntity = baseEntity;
				}
				
				for each(var variable:Object in typeDef.fields){
					
					if (variable is Accessor && !variable.writeable){
						continue;
					}
					
					var varName:String = variable.name;
					var typeName:String = variable.type.name;
					
					
					
					if (kinveyObject.hasOwnProperty(varName)){
						if (typeName == "Array"){
							var kinveyMethod:Array = kinveyObject[varName] as Array;
							if (kinveyMethod && kinveyMethod.length >0){
								//Referernce object in array
								if (kinveyMethod[0].hasOwnProperty("_collection")){
									var childBaseEntity:String = kinveyMethod[0]._collection;
									var childArray:Array = new Array;
									for each (var childItem:Object in kinveyMethod){
										if (childItem.hasOwnProperty("_obj")){
											var myChildObj:Object = mapObject(childBaseEntity,childItem._obj);
											if (myChildObj){
												childArray.push(myChildObj);
											}
										}
									}
									myObject[varName] = childArray;
								}
								else{
									myObject[varName] = kinveyMethod;
								}
							}
						}else if (typeName == "String" || typeName == "Number" || typeName == "int" || typeName == "Boolean" ){
							myObject[varName] = kinveyObject[varName];
						}else if (typeName == "Date"){
							//2014-05-18T13:53:34.264Z
							var dateString:String = kinveyObject[varName];
							
							if (!dateString){
								continue;
							}
							
							var finalDate:Date = dateUtil.parseDateTimeString(dateString);
							myObject[varName] = finalDate;
							
						}
						else if (typeName == "KinveyFile"){
							var kinFile:KinveyFile = new KinveyFile();
							kinFile.entity = kinveyObject[varName];
							myObject[varName] = kinFile;
						}
						else if (dict[typeName]){
							var ref:Object = kinveyObject[varName];
							if (ref._type == "KinveyRef"){
								if (ref.hasOwnProperty("_obj") && ref._obj){
									myObject[varName] = mapObject(typeName,ref._obj);
								}
								else{
									myObject[varName] = mapObject(typeName,ref);
								}
								myObject[varName].isReference=true;
							}
						}
					}
				}
				
			}
			
			return myObject;
		}
		
		public function initialize(kinveyBeans:Array):void
		{
			kinveyBeans.push(KinveyUser,KinveyError);
			
			for each (var item:Class in kinveyBeans){
				var type:Type = Type.forClass(item);
				dict[type.name] = type;
			}
			
		}
		
		public function prepareForSave(kinveyObject:KinveyEntity):void{
		
			kinveyObject.valueChanged = false;
			
			var typeDef:Type = dict[kinveyObject.baseEntity];
			if (!typeDef) return ;
			
			if (!kinveyObject.entity){
				kinveyObject.isNew = true;
				kinveyObject.valueChanged = true;
				kinveyObject.entity = new Object;
			}
			
			for each(var variable:Variable in typeDef.variables){
				
				if (variable.hasMetadata("Transient")){
					continue;
				}
				
				var varName:String = variable.name;
				var typeName:String = variable.type.name;
				
				if (typeName == "Date" ){
					var normalDate:Date = kinveyObject[varName];
					var isoDate:String;
					if (normalDate)
						isoDate = dateUtil.formatExtendedDateTime(normalDate); 
					if (kinveyObject.isNew || isoDate != kinveyObject.entity[varName]){
						kinveyObject.entity[varName] = isoDate;
						kinveyObject.valueChanged = true;
					}
				}
				else if (typeName == "String" || typeName == "Number" || typeName == "int" || typeName == "Boolean" ){
					if (kinveyObject.isNew || kinveyObject[varName] != kinveyObject.entity[varName]){
						kinveyObject.entity[varName] = kinveyObject[varName];
						kinveyObject.valueChanged = true;
					}
				}
				else if (typeName == "Array"){
					//Check if array values are different
					if (kinveyObject.isNew || kinveyObject[varName] != kinveyObject.entity[varName]){
						kinveyObject.entity[varName] = kinveyObject[varName];
						kinveyObject.valueChanged = true;
					}
				}
				else if (dict[typeName] || typeName == "KinveyFile"){
					var ref:KinveyEntity = kinveyObject[varName];
					//Ronny: Always override with reference item so we never send the whole object
					kinveyObject.valueChanged = true;
					kinveyObject.entity[varName] = ref.kinveyRef;
				}
			}
		}
		
		public function processFunction(fun:Function, obj:Object):void{
			if (fun!=null){
				fun(obj);
			}
		}
		
		public function encode(string:String):String{
			
			var encoder:Base64Encoder = new Base64Encoder(); 
			encoder.insertNewLines = false; 
			encoder.encode(string);
			return encoder.toString();	
		}
		
		
		public function partial( func : Function, ...boundArgs ) : Function {
			return function( ...dynamicArgs ) : * {
				return func.apply(null, boundArgs.concat(dynamicArgs))
			}
		}
		
	}
}