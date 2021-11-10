#!/usr/bin/env node
//import axios from 'axios';
const express = require('express');
//const schedule = require('node-schedule');
//const sched = require('./schedule-notif');

const app = express()

app.use(
  express.urlencoded({
    extended: true
  })
)

app.use(express.json())

console.log("Testing 1")
const { spawn } = require('child_process')
const child = spawn('node', ['schedule-notif.js'], {detached: true})
//const sn = spawn('ls')
// const sn = exec('node schedule-notif.js')

child.stdout.on('data', (data) => {
    console.log(`stdout: ${data}`)
  })

child.on('error', (err) => {
    console.error(`Failed to start subprocess. ${err}`)
})

child.on('spawn', (spw) => {
    console.log('Process spawned successfully')
})
console.log("Testing 2")

child.on('close', () => {
    console.log("It closed")
})

child.on('exit', () => {
    console.log("It exited")
})
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

    //sched.scheduleNotif.start();
    //woe is I 
    /*
    //const date = new Date(req.body.year, req.body.month-1, req.body.day, req.body.hour, req.body.minute, 0)
    //Date is dumb and wasn't working. This is minute, hour, day, month, dumb
    //const date = `${r.minute} ${r.hour} ${r.day} ${r.month} *`
    const date = '15 20 9 11 *'
    //const job = schedule.scheduleJob(date, function(x) {sendNotif(x.topic, x.url, x.title, x.message)}.bind(null, r));
    //const job = schedule.scheduleJob(date, function() {console.log("Why isn't this working!?!?!")})
    scheduleJob(date)
    */
    //sn.kill('SIGKILL');
    
    process.kill(-child.pid, 'SIGTERM');
    process.kill(-child.pid, 'SIGKILL');
    res.send("Success")
})

app.listen(3000, () => {
    console.log(`App listening at http://localhost:3000`)
  })



// async function scheduleJob(date) {
//     const job = schedule.scheduleJob(date, function() {console.log("Why isn't this working!?!?!")})
// }

// function sendNotif(topic, url, title, body) {
//     const admin = require("firebase-admin");
//     const credentials = require("./ema-ramen-firebase-adminsdk-7lvc1-45079796ab.json");

//     admin.initializeApp({
//         credential: admin.credential.cert(credentials),
//         databaseURL: "https://ema-ramen-default-rtdb.firebaseio.com",
//     });

//     const message = {
//         data: {
//             url: url
//         },
//         topic: topic,
//         notification: {
//             title: title,
//             body: body,
//         },
//     };


//     admin.messaging()
//         .send(message)
//         .then((response) => {
//             console.log("Successfully sent message:", response);
//         })
//         .catch((error) => {
//             console.log("Error sending message:", error);
//         });
// }
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