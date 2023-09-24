
//Declare needed vars
var auth, token

//Callback called when context of an extension is fired 
window.Twitch.ext.onContext((context) => {
  console.log("OUTPUT: Context Run");
});

//Extension login to twitch
window.Twitch.ext.onAuthorized((auth) => {
  token = auth.token; //JWT to EBS
  console.log("OUTPUT: App Login");
});
