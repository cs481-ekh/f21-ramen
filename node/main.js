//import axios from 'axios';
//import express from 'express';

const schedule = require('node-schedule');

const job = schedule.scheduleJob('0 * * * *', function() {sendNotif("notif_test","https://www.npmjs.com/package/node-schedule","Testing again","Sorry for spam")});

function sendNotif(topic, url, title, body) {
    const admin = require("firebase-admin");
    const credentials = require("./ema-ramen-firebase-adminsdk-7lvc1-45079796ab.json");

    admin.initializeApp({
        credential: admin.credential.cert(credentials),
        databaseURL: "https://ema-ramen-default-rtdb.firebaseio.com",
    });

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
//general structure for sending a post using axios
/*
axios
  .post('https://whatever.com/todos', {
    todo: 'Buy the milk'
  })
  .then(res => {
    console.log(`statusCode: ${res.status}`)
    console.log(res)
  })
  .catch(error => {
    console.error(error)
  })
*/

//General structure for recieving JSON, from tutorial on NodeJS website
/*
const app = express()

app.use(
  express.urlencoded({
    extended: true
  })
)

app.use(express.json())

app.post('/test', (req, res) => {
  console.log(req.body.todo)
})
*/