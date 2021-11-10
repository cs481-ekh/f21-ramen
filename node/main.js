//import axios from 'axios';
const express = require('express');
const schedule = require('node-schedule');
var CronJob = require('cron').CronJob;

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

    
    var job = new CronJob('26 20 9 11 *', function() {
        console.log('You will see this message every second');
    }, null, true);
    job.start();
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
    res.send("Success")
})

app.listen(3000, () => {
    console.log(`App listening at http://localhost:3000`)
  })



// async function scheduleJob(date) {
//     const job = schedule.scheduleJob(date, function() {console.log("Why isn't this working!?!?!")})
// }

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