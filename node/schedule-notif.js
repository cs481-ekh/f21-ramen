#!/usr/bin/env node
var node = require('node-schedule');
const admin = require("firebase-admin");

const credentials = require("./ema-ramen-firebase-adminsdk-7lvc1-45079796ab.json")

admin.initializeApp({
    credential: admin.credential.cert(credentials),
    databaseURL: "https://ema-ramen-default-rtdb.firebaseio.com",
});

console.log("It's working, process started?!")

//sendNotif("notif_test", "https://nodejs.dev/learn/reading-files-with-nodejs", "Child process test", "Will this work yet?")

var scheduleNotif = node.scheduleJob('25 15 10 11 *', function(){
    console.log("It's working, send notif?!")
    sendNotif("notif_test", "https://nodejs.dev/learn/reading-files-with-nodejs", "Test1", "This should show up")
});

var scheduleNotif2 = node.scheduleJob('26 15 10 11 *', function(){
    console.log("It's working, send notif?!")
    sendNotif("notif_test", "https://nodejs.dev/learn/reading-files-with-nodejs", "Test2", "The process wasn't killed correctly")
});

function sendNotif(topic, url, title, body) {

    const message = {
        data: {
            url: url
        },
        topic: topic,
        notification: {
            title: title,
            body: body,
        },
    };


    admin.messaging()
        .send(message)
        .then((response) => {
            console.log("Successfully sent message:", response);
        })
        .catch((error) => {
            console.log("Error sending message:", error);
        });
}