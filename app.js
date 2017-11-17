var express      = require('express'),
    app          = express(),
    session      = require('express-session'),
    admin        = require("firebase-admin"),
    bodyParser   = require("body-parser");
    
//Configurations-------------------------------------------------------------->

app.use(bodyParser.urlencoded({extended : true}));
app.use(express.static(__dirname));
app.use(express.static(__dirname + '/public'));
app.set('view engine', 'ejs');

app.use(session({
    cookieName: 'session',
    secret: "Secret Louis P3P",
    resave: false,
    saveUninitialized: false,
    duration: 30 * 60 * 1000,
    activeDuration: 5 * 60 * 1000,
    secure : true
}));

var serviceAccount = require("./private/facebooksafetymesh-firebase-adminsdk-oohp3-98725d0686");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://facebooksafetymesh.firebaseio.com"
});

//****************************Azure Stuff

//Middleware------------------------------------------------------------------>

//Routes---------------------------------------------------------------------->

var facebook = require('./routes/facebook'),
    maps     = require('./routes/maps');
    
app.use(facebook);
app.use(maps);

//****************************

// var http = require("http");
// setInterval(function() {
//     http.get("http://m3sh.herokuapp.com/");
//     console.log("pinged");
// }, 30000); 

app.listen(process.env.PORT, process.env.IP, function(){
    console.log("Facebook REST API Server Started!");
});