
     ,-----.,--.                  ,--. ,---.   ,--.,------.  ,------.
    '  .--./|  | ,---. ,--.,--. ,-|  || o   \  |  ||  .-.  \ |  .---'
    |  |    |  || .-. ||  ||  |' .-. |`..'  |  |  ||  |  \  :|  `--, 
    '  '--'\|  |' '-' ''  ''  '\ `-' | .'  /   |  ||  '--'  /|  `---.
     `-----'`--' `---'  `----'  `---'  `--'    `--'`-------' `------'
    ----------------------------------------------------------------- 

Facebook REST API Server - 
Facebook Developers
Google Firebase and Maps - https://console.firebase.google.com/u/0/project/facebooksafetymesh/database/facebooksafetymesh/data
https://developers.google.com/maps/documentation/javascript/custom-markers

## 0) Data Received

- Facebook ID
- Latitude
- Longitude
- Altitude
- Status
- Name
- Email

## 1) Store Data and Display On Maps With Heat 

- Put data entries in DB + time
- Map Heatmaps in maps.ejs and  icons (Csaba)

## 2) Send Data To messenger or User Page

- Post onto user page
- Post to pages (Colin) not: messenger

## 3) Stuffs
var outerKey = [{
         fb_id : 1,
         latitude : 53.544008,
         longitude : -113.572632,
         altitude : 2000,
         status : 0,
         name : 'l',
         email : 'l@hotmail.com'
    },{
        fb_id : 2,
         latitude : 53.543620,
         longitude : -113.574024,
         altitude : 222,
         status  : 1, 
         name : 'l1',
         email : 'l1@gmail.com'
    },
    {
        fb_id : 3,
         latitude : 53.542995,
         longitude : -113.578056,
         altitude : 500,
         status  : 0, 
         name : 'l2',
         email : 'l2@g
         }];