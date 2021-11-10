import axios from 'axios';
import express from 'express';
import { initializeApp } from 'firebase-admin/app';

//For security reasons this has to be hardcoded when testing. We shouldn't store the key in our repository
var serviceAccount = require("path/to/serviceAccountKey.json");

const app = initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://ema-ramen-default-rtdb.firebaseio.com"
});

const message = {
    data: {
        url: "https://en.wikipedia.org/wiki/Node.js"
    },
    topic: "test-notif",
    notification: {
        title: "Test from NodeJS",
        body: "Did this work properly?",
    },
};
  
app.messaging()
    .send(message)
    .then((response) => {
      console.log("Successfully sent message:", response);
    })
    .catch((error) => {
      console.log("Error sending message:", error);
    });
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