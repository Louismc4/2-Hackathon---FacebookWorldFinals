var express = require('express'),
    router  = express.Router(),
    admin   = require('firebase-admin'),
    geocoder= require('geocoder');
    
var db = admin.database();

router.get('/', function(request, response){
    db.ref('/').once('value').then(function(snapshot){
        var results = [snapshot.val().users];
        console.log(results);
        response.render('../views/maps', {results : results});
    });
});

module.exports = router;