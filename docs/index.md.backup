# Ecological Momentary Assessment (EMA) App
![EMA App Logo: simple graphic of person holding clipboard](../assets/images/logo.png)

### Created by Paisley Davis, Chloe Johnson, and Mason Humpherys

## Abstract:

Ecological Momentary Assessment (EMA) is a data collection approach which requires participants to answer very brief surveys at specific moments in their daily lives. The goal of this project is to create a mobile app that will make the survey collection process easier and more efficient for both researchers and participants. 

Our app is meant to act as an interface between surveys hosted on Qualtrics and participants' smartphones. It facilitates the collection of EMA data while providing customization options for both parties, such as researcher-scheduled reminders, notification muting, and a visual streak system that provides psychological rewards for completing surveys. We hope this app can improve the survey-taking process, both increasing participants’ satisfaction with it and the quantity and quality of the data collected.  
  
This app is currently a work-in-progress and does not fulfill all necessary functionality. 

## Project Description:

Our app is built using [Flutter](https://flutter.dev/). Currently, we have only been able to test it on mobile Android devices, though Flutter is meant to allow cross-platform implementation. 

In its current state, users of the app can create an account, login, subscribe to projects, and receive notifications containing survey links once subscribed to a project. Opened notifications will direct the user to the specified Qualtrics survey.   
  
Login screen as viewed upon opening app for the first time:  

![](images/login.png)  
  
The app also has persistent login capabilities, so users only have to login once per device. 

When registering as a new user, users provide a "project ID" which is used to subscribe them to a previously-created Firebase notification list.  
  
The UI is currently set-up for admin users to send notifications and view and manage projects, but the functionality only supports new project creation.  

![](images/admin.png) 
![](images/new-project.png)  
  
However, hardcoded device-to-server-to-device notification broadcasting has been successfully tested, and notifications can be sent immediately from the Firebase console for testing. 
  
If the app is closed or in the background, the notification will appear as a regular push notification.   
  
![](images/notif.png)

If the app is open and logged into a regular user account, the notification will appear in the notification list on the main screen.   
  
![](images/in-app.png)

Selecting either notifications will open the notification's containing link in the device's default browser. 

![](images/link-site.png)

When a hard coded notification is scheduled from a device, an independent Node.js server captures these notifications and sends them to [Firebase](https://firebase.google.com/) to be distributed at the specified time. 

Presently, notification management within the app itself is mostly non-existent; admin users don't have any management or control options once notifications are submitted. 

User management can also only be done through the Firebase console. More robust user and project management is planned for the future, with basic UI elements in place for coming implementations.
  
![](images/project-list.png)
