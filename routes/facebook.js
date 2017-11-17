var express = require('express'),
    router  = express.Router(),
    admin   = require('firebase-admin'),
    geocoder= require('geocoder'),
    graph   = require('fbgraph');
    
var db = admin.database();

router.post('/facebookInit', function(request, response){
    var outerKey = '';
    var fb_id;
    var latitude = 0;
    var longitude = 0;
    var altitude = 0;
    var status = 1;
    var address = '';
    var name = '';
    var picture = '';
    var token = '';
    var statusString = '';
    
    for(var key in request.body){
        outerKey = JSON.parse(key);
        break;
    }
    
    console.log(outerKey);
    
    if(typeof outerKey['fb_id'] == 'undefined'){
        response.end();
        return;
    } else {
        
        console.log(outerKey);
        fb_id = outerKey['fb_id'];
        latitude = outerKey['latitude'];
        longitude = outerKey['longitude'];
        address = outerKey['address'];
        altitude = outerKey['altitude'];
        status = outerKey['status'];
        name = outerKey['name'];
        token = outerKey['token'];
        
        graph.setAccessToken(token);
        
        db.ref('/users/' + fb_id + '/').set({['fb_id'] : fb_id, ['latitude'] : latitude, ['longitude'] : longitude, ['altitude'] : altitude, 
            ['date'] : Date.now(), ['address'] : address, ['statusString'] : '', ['status'] : status, ['name'] : name}).then(function(snapshot){
            graph.get("me" + "/?fields=picture", function(error, resp) {
                if(error){
                    console.log(error);
                    response.send({['message'] : 'Error : Facebook Init Post Error!'});
                } else {
                    picture = resp.picture.data.url;
                    db.ref('/users/' + fb_id + '/').update({['picture'] : picture}).then(function(snapshot){
                    }, function(error){
                        if(error){
                            response.send({['message'] : 'Error : ' + error});
                        }
                    });
                }
            });
        }, function(error){
            if(error){
                response.send({['message'] : "Error : Database Write Fail!"});
                return;
            } 
        });
    }
});

//Facebook Route
router.post('/facebookpost', function(request, response){
    var outerKey = '';
    var fb_id;
    var latitude;
    var longitude;
    var altitude = 0;
    var status;
    var name = '';
    var picture = '';
    var token = '';
    
    for(var key in request.body){
        outerKey = JSON.parse(key);
        break;
    }
    
    console.log(outerKey);
    
    if(typeof outerKey['fb_id'] == 'undefined' || typeof outerKey['latitude'] == 'undefined' 
        || typeof outerKey['longitude'] == 'undefined' || typeof outerKey['status'] == 'undefined'
        || typeof outerKey['token'] == 'undefined'){
        response.send({['fb_id'] : fb_id, ['message'] : "Error : Bad Values!"});
    } else {
        fb_id = outerKey['fb_id'];
        latitude = outerKey['latitude'];
        longitude = outerKey['longitude'];
        altitude = outerKey['altitude'];
        status = outerKey['status'];
        name = outerKey['name'];
        token = outerKey['token'];
        
        graph.setAccessToken(token);
        
        geocoder.reverseGeocode(latitude, longitude, function ( err, data ) {
            if(err){
                response.send({['fb_id'] : fb_id, ['message'] : "Error : Changing Your Coordinates To An Address!"});
            } else {
                if(data.results[0] != undefined){
                    db.ref('/users/' + fb_id + '/').update({['latitude'] : latitude, ['longitude'] : longitude, ['altitude'] : altitude, 
                        ['date'] : Date.now(), ['address'] : data.results[0].formatted_address, ['status'] : status}).then(function(snapshot){
                            graph.get("me" + "/?fields=picture", function(error, resp) {
                                if(error){
                                    console.log(error);
                                    response.send({['fb_id'] : fb_id, ['message'] : 'Error : Facebook Post Error!'});
                                } else {
                                    picture = resp.picture.data.url;
                                    db.ref('/users/' + fb_id + '/').update({['picture'] : picture}).then(function(snapshot){
                                        //***
                                        //facebookMessengerPost(fb_id, status, data.results[0].formatted_address, altitude, name, token, request, response);
                                        facebookPagePost(fb_id, status, data.results[0].formatted_address, altitude, name, token, request, response)
                                        var statusString = '';
                                        if (status == 0){
                                            statusString = 'Needs Assistance';
                                        } else if (status == 1){
                                            statusString = 'Safe';
                                        }
                                        console.log(statusString);
                                        db.ref('/users/' + fb_id).update({'/statusString' : statusString}).then(function(snapshot){
                                            db.ref('/users/' + fb_id).once('value').then(function(snapshot){
                                                var msg = name + ": Status Update - In need of help. \n Address : " + data.results[0].formatted_address + ". \n Latitude : " + outerKey["latitude"] + ".\n Longitude :  " + outerKey["longitude"] + ".\n Altitude : " + outerKey["altitude"];
                                                var wallPost = {
                                                  message: msg
                                                }
                                                if(status == 0){
                                                    graph.post("/feed/?privacy={'value':'SELF'}", wallPost, function(err, res) {
                                                        if(err){
                                                            console.log(err);
                                                            response.send({['fb_id'] : fb_id, ['message'] : "Error : Facebook Post Error!"});
                                                            return;
                                                        } else {
                                                            // returns the post id
                                                            console.log(res); // { id: xxxxxx
                                                            response.send({['fb_id'] : fb_id, ['message'] : "Hang on " + name + ". First responders are on their way."});
                                                        }
                                                    });
                                                }
                                            });
                                        });
                                    }, function(error){
                                        if(error){
                                            response.send({['fb_id'] : fb_id, ['message'] : 'Error : ' + error});
                                        }
                                    });
                                }
                            });
                        }, function(error){
                            if(error){
                                response.send({['fb_id'] : fb_id, ['message'] : "Error : Database Write Fail!"});
                                return;
                            } 
                        });
                } else {
                    response.send({['fb_id'] : fb_id, ['message'] : "Error : Address Returned Undefined!"});
                    return;
                }
            }
        });
    }
});

var facebookPagePost = function(fb_id, status, address, altitude, name, token, request, response){
    graph.setVersion('2.11');
    var cfg = { "page_id" : "522354384791944", "access_token" : "EAACrIZCHE7c8BAPTPdStymmLSwtgHVpT7TspAZAk9Da0tuk7ZCAfSVt6Vp9vtaXcAqmkrnwyZCwP7jws3f6bUhw3AS0Ok1jkC0qeOfi5siCZCfOsyVRc4nMHZA4VNmnsJ7zWW9Wjomc56LUQujZBfN1jmlen00WcQ4h64LNCOxCyQZDZD"};
    
    graph.setAccessToken(cfg['access_token']);
    
    graph.get("me/accounts", function(error, resp) {
        if(error)console.log(error);
        else {
            for(var page in resp['data']) {
                if (page['id'] == cfg['page_id']) {
                    console.log(page['access_token']);
                }
            }
        }
    });
    
    var wallPost = {
      message: "Hello Nubby World"
    };
     
    graph.post("/feed", wallPost, function(err, res) {
      // returns the post id 
      if(err)console.log(err);
      else console.log(res); // { id: xxxxx} 
    });
};


module.exports = router;