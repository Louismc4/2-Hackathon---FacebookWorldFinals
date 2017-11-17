/*
router.get('/facebook', function(request, response){
    console.log("facebook routed!");
    facebookMessengerPost(response);
});

var facebookMessengerPost = function(response){
    var FBMessenger = require('fb-messenger');
    //*** Token ended
    graph.setVersion('2.11');
    var token = "EAACEdEose0cBAG6banb9DIboBgzs5Ci5tBLnnRadCkDZA2wgwzbP0esdS6Yjw1FnJAUrAFzXjnGaXbMsXd1Efm6cB97zf1Kl1AZBA1OqKxzxHIuiRTU3ESXUeYY9tSiuuV2rKuHK55frkojvAEWMAbuNSPntY1b7KmwbhkG5YfRrmVQYIJToXZArfx2siiyMZAoxXwSdp5AN0hAs0XjGiiFVij4D7cQZD";
    graph.setAccessToken(token);
    // graph.setVersion('2.11');
    graph.get("me/?fields=id,friends", function(error, resp) {
        if(error){console.log(error); 
        
        }
        else 
        {
            console.log(resp);
            var user_data = resp;
            var messenger = new FBMessenger(token);
            var friends;
           for (var key in resp) {
                if (resp.hasOwnProperty(key)) {
                    console.log(key + " -> " + resp[key]);
                    if(key == 'friends'){
                        friends = resp[key]['data'];
                        break;
                    }
                }
            }
            
            var count = friends.length;
            
            var iter = 0;
            sendBatchMessages(iter);    
                
            function sendBatchMessages(iter){
                console.log(friends[iter]['id']);
                messenger.sendTextMessage("1346069452075811", msg, function(err, body) {
                    if(err) return console.log(err);
                    console.log(body);
                    if(iter < count){
                        iter++;
                        sendBatchMessages(iter);
                    }
                });
            }
                    //console.log(resp);
                    // console.log(resp['friends']['data'][0]);
                    // messenger.sendTextMessage(resp['friends']['data'][0]['id'], msg, function(err, body) {
                    //         if(err) return console.log(err);
                    //         console.log(body);
                    //     });
                    
                }
        });
    
    
    var msg = "Hello Test";
}
*/
// var facebookMessengerPost = function(fb_id, status, address, altitude, name, token, request, response){
//     var FBMessenger = require('fb-messenger');
//     var messenger = new FBMessenger("");
    
//     var msg = "test";
    
//     messenger.sendTextMessage("", 'Hello', function (err, body) {
//       if(err) return console.error(err);
//       console.log(body);
//     });
    
//     console.log("after");
    
//     // curl -X POST -H "Content-Type: application/json" -d '{
//     //   "messaging_type": "<MESSAGING_TYPE>",
//     //   "recipient": {
//     //     "id": "<PSID>"
//     //   },
//     //   "message": {
//     //     "text": "hello, world!"
//     //   }
//     // }' "https://graph.facebook.com/v2.6/me/messages?access_token=<PAGE_ACCESS_TOKEN>"
// };