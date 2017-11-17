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
    
    console.log(request.body);
    
    // for(var key in request.body){
    //     outerKey = JSON.parse(key);
    //     break;
    // }
    
    console.log(outerKey);
    
    // if(typeof outerKey['fb_id'] == 'undefined' || typeof outerKey['latitude'] == 'undefined' 
    //     || typeof outerKey['longitude'] == 'undefined' || typeof outerKey['status'] == 'undefined'
    //     || typeof outerKey['token'] == 'undefined'
        if (2==3){
        response.send({['fb_id'] : fb_id, ['message'] : "Error : Bad Values!"});
    } else {
        fb_id = outerKey['fb_id'];
        latitude = Number(outerKey['latitude']);
        longitude = Number(outerKey['longitude']);
        altitude = 0;
        status = Number(outerKey['status']);
        name = outerKey['name'];
        token = outerKey['token'];
        
        console.log(outerKey);
        
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
                                                        console.log("XD3");
                                                        if(err){
                                                            console.log(err);
                                                            response.send({['fb_id'] : fb_id, ['message'] : "Error : Facebook Post Error!"});
                                                            return;
                                                        } else {
                                                            // returns the post id
                                                            console.log(res); // { id: xxxxxx
                                                            console.log("XDDD");
                                                            //facebookPagePost(token);
                                                            facebookPagePost(token,name,status,data.results[0].formatted_address);
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

router.get('/facebookget', function(request, response){
    var responseArray = [];
    var str = '';
    db.ref('/users').once('value').then(function(snapshot){
        var val = snapshot.val()
        for (var key in val) {
            if (val.hasOwnProperty(key)) {
                str += val[key]['latitude'] + ',' + val[key]['longitude'] + ',';
                // responseArray.push(val[key]['latitude']);
                // responseArray.push(val[key]['longitude']);
            }
        }
        response.send(str);
    });
});

var facebookPagePost = function(token,name,status,address){
    graph.setVersion('2.11');
    
    var user_token = token;
    graph.setAccessToken(user_token);

    var contact_names = {};
    var last_name = "";
    // get all close friends to add their tagID to tag string
    graph.get("me?fields=last_name", function(error, resp) {
        if(error)console.log(error);
        else {
            last_name = resp.last_name;
            graph.get("me/family", function(error, resp) {
                if(error)console.log(error);
                else {
                    for (var i = 0; i < resp.data.length; i++) {
                        contact_names[resp.data[i].name] = resp.data[i].id;
                    }
                    console.log(contact_names);
                    graph.get("me/taggable_friends", {limit: 300}, function(error, resp) {
                        if(error)console.log(error);
                        else {
                            var tag_string = "";
                            console.log(last_name);
                            for (var g = 0; g < resp.data.length; g++) {
                                if (contact_names[resp.data[g].name] != null) {
                                    if (tag_string != "") tag_string = tag_string + ", ";
                                    tag_string = tag_string + resp.data[g].id;
                                }/* else if (resp.data[g].name.split(" ")[1] == last_name) {
                                    if (tag_string != "") tag_string = tag_string + ", ";
                                    tag_string = tag_string + resp.data[g].id;
                                }*/
                            }
                            console.log("Tag String", tag_string);
                            //var cfg = { "page_id" : "522354384791944", "access_token" : "EAACrIZCHE7c8BAPTPdStymmLSwtgHVpT7TspAZAk9Da0tuk7ZCAfSVt6Vp9vtaXcAqmkrnwyZCwP7jws3f6bUhw3AS0Ok1jkC0qeOfi5siCZCfOsyVRc4nMHZA4VNmnsJ7zWW9Wjomc56LUQujZBfN1jmlen00WcQ4h64LNCOxCyQZDZD"};
                            //var cfg = { "page_id" : "522354384791944", "access_token" : "EAACrIZCHE7c8BAOZC8tIPvyL3ZCFckvyWrjshwv9XpmnzTeSICFDPBcnr1mrsZBaV27sPfNszJDjtn8LZAU7XFQ9P0djlM8eHqZB6eZABwmKSZBkvATsZBntVq2OfSqg3HJhsbfjcZAZAGsASFT02WeJZAzIm76d2tBP0hD2fFIZCaM0FAAF2INIFcxCM"};
        
                            var cfg = { "page_id" : "126217038058537", "access_token" : "EAACrIZCHE7c8BANwJn5AzhbUxV80ZCGxRpxniK7ZC1lE5APSnXqQpfM8IbHfuyKS0qBiS9F34S83t8utegXdShNXVZBlZAlWM89TajM9HdNAgolzjMYnw4LbvKmN7V8xwGr7JhMCUiHIsED92oTmE4A52sfH4UCzcP1aJYyPM5jAU9jiSrZCR2"};
                            
                            graph.setAccessToken(user_token);
                            var state = "";
                            if (status == 0) state = "Needs Assistance";
                            else state = "Safe";
                            var wallPost = {
                                message: name + "\n" + state + "\n" + address,
                                tags: tag_string
                            };
                             
                            graph.post("126217038058537/feed", wallPost, function(err, res) {
                              // returns the post id 
                              if(err)console.log(err);
                              else console.log(res);
                            });
                        }
                    });
                }
            });
        }
    });
};


module.exports = router;