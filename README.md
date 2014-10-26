FlexKinveyLib
=============
Flex SDK/AS3 integration with Kinvey BaaS REST API

The purpose of this library is to ease communication with Kinvey by Converting JSON Objects retrieved from Kinvey into AS3 Typed Objects. Very Similar to what Hibernate is to Java.
re
Kinvey.instance.initialize("appkey","token","username","password",[PurchaseItems,Themes,ThemeCategory],defaultFaultHandler);

Kinvey.instance.login(username,password,resultHandler,loginFaultHandler);

Kinvey.instance.updateUser(username,name,updateUserResult);

Kinvey.instance.signUp(username,password,fullName,result,signUpError);

Kinvey.instance.saveEntity(item,callBackHandler);	

Kinvey.instance.checkUserExists(email,userExists);

Kinvey.instance.passwordReset(user,passwordResetHandler);	

new CollectionCritria("TableName",null,auth).resolve("category").addFilter("isPrivate",false).addResultHandler(callBack).list();
