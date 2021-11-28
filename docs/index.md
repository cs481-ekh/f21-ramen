# Ecological Momentary Assessment (EMA) App

### Created by Paisley Davis, Chloe Johnson, and Mason Humpherys

## Abstract:

Ecological Momentary Assessment (EMA) is a data collection approach which requires participants to answer very brief surveys at specific moments in their daily lives. The goal of this project is to create a mobile app that will make the survey collection process easier and more efficient for both researchers and participants. 

The completed app is meant to act as an interface between surveys hosted on Qualtrics and participants' smartphones. It will facilitate the collection of EMA data while providing customization options for both parties, such as researcher-scheduled reminders, notification muting, and a visual streak system that provides psychological rewards for completing surveys. In this way, we hope to improve the survey-taking process, both increasing participants’ satisfaction with it and the quantity and quality of the data collected.

## Project Description:

Our app is built using [Flutter](https://flutter.dev/). Currently, we have only been able to test it on mobile Android devices, though Flutter is meant to allow cross-platform implementation. 

In its current state, users of the app can create an account, login, subscribe to projects, and receive notifications containing survey links once subscribed to a project. Opened notificatoin will direct the user to the specified 

These scheduled survey notifications are created and deployed on the app by adminstrative accounts. In the background, an independent Node.js server captures these notifications and sends them to [Firebase](https://firebase.google.com/) to be distributed at the specified time. Presently, notification management within the app itself is mostly non-existent; admin users don't have any management or control options once notifications are submitted. 

At the moment, user management can only be done through the Firebase console. More robust user and project management is planned for the future, with basic UI elements in place for the back-end implementation. 
