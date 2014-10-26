FlexKinveyLib
=============
Flex SDK/AS3 integration with Kinvey BaaS RESTUL API

The purpose of this library is to ease communication with Kinvey by Converting JSON Objects retrieved from Kinvey into AS3 Typed Objects. Very Similar to what Hibernate is to Java. (But offcource not even 1% Close functionality wise)  

//Initialize Kinvey
Kinvey.instance.initialize("appkey","token","username","password",[PurchaseItems,Themes,ThemeCategory],defaultFaultHandler);

//Login
public function login(username:String, password:String, resultHandler:Function):void{
	Kinvey.instance.login(username,password,resultHandler,loginFaultHandler);
}

public function updateUser(username:String, name:String):void{
	Kinvey.instance.updateUser(username,name,updateUserResult);
}

private function loginFaultHandler(kinveyError:KinveyError):void
{
	if (!kinveyError.isIO){
		Alert.show(kinveyError.showError());
	}
	else{
		Alert.show("Invalid Credentials");
	}
}
		
//Signup
public function signUp(username:String,password:String, fullName:String, result:Function,signUpError:Function=null):void{
	Kinvey.instance.signUp(username,password,fullName,result,signUpError);
}

//Delete Item
public function deleteItem(hashtag:PurchaseItems,delteCallback:Function):void
{
	for each (var item:PurchaseItems in purchasedItems){
		if (item.id == hashtag.id){
			item.isDeleted = true;
			Kinvey.instance.saveEntity(item,delteCallback);
			return;
		}
	}
}

//Save entity to kinvey	
public function purchaseItem(purchaseItem:PurchaseItems,purchaseHandler:Function):void
{
	purchaseItem.user = Kinvey.instance.currentUser.id;
	purchaseItem.isActivated = true;
	Kinvey.instance.saveEntity(purchaseItem,purchaseHandler);	
}

public function passwordReset(email:String):void
{
	App.instance.showLoader();
	Kinvey.instance.checkUserExists(email,userExists);
}

private function userExists(exists:Boolean,user:String):void
{
	if (exists){
		Kinvey.instance.passwordReset(user,passwordResetHandler);	
	}
	else{
		Alert.show("Please verify your email address");
	}
}	

//Load Collection Examples
public function loadAllThemes(callBack:Function):void{
	var auth:int = App.instance.userLoggedIn ? Kinvey.AUTH_TOKEN : Kinvey.AUTH_PUBLIC;
	new CollectionCritria("Theme",null,auth).resolve("category").addFilter("isPrivate",false).addResultHandler(callBack).list();
}
public function loadPurchasedItem(id:String=null, result:Function=null):void{
	var collection:CollectionCritria = new CollectionCritria("PurchaseItem").addFilter("user",Kinvey.instance.currentUser.id).resolveAll("3").addResultHandler(ViewUtil.partial(loadPurchasedItemResult,result));
	collection.addFilter("_id", id);
	collection.list();
}
public function loadPurchasedItemResult(resultHandler:Function,result:Array):void{
}


		
