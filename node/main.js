#!/usr/bin/env node
const express = require('express');
const schedule = require('node-schedule');
const admin = require("firebase-admin");

const credentials = require("./ema-ramen-firebase-adminsdk-7lvc1-45079796ab.json");

admin.initializeApp({
    credential: admin.credential.cert(credentials),
    databaseURL: "https://ema-ramen-default-rtdb.firebaseio.com",
});

const app = express()

app.use(
  express.urlencoded({
    extended: true
  })
)

app.use(express.json())

/*
JSON FORMAT THAT I JUST CAME UP WITH
{
    topic:
    url:
    title:
    message:
    year: 
    month:
    day:
    hour:
    minute:
}
*/
app.get('/', (req, res) => {
    res.send('Hello World!')
  })

app.post('/test', (req, res) => {
    console.log(req.body)
    const r = req.body
    
    const date = new Date(req.body.year, req.body.month-1, req.body.day, req.body.hour, req.body.minute, 0)

    const job = schedule.scheduleJob(date, function(x) {sendNotif(x.topic, x.url, x.title, x.message)}.bind(null, r));

    res.send("Success\n")
})

app.listen(3000, () => {
    console.log(`App listening at http://localhost:3000`)
  })


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