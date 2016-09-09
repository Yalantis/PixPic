# PixPic

## PixPic, a Photo Editing App Built by Our iOS Interns 

<img src="Screenshots/5.5%20Device%200.jpg" width="250" />
<img src="Screenshots/5.5%20Device%201.jpg" width="250" />
<img src="Screenshots/5.5%20Device%202.jpg" width="250" />
<img src="Screenshots/5.5%20Device%203.jpg" width="250" />
<img src="Screenshots/5.5%20Device%204.jpg" width="250" />
<img src="Screenshots/5.5%20Device%205.jpg" width="250" />

What's the best way to teach interns how to write an iOS app? Just let them do it! This app is the result of our interns’ collaboration.
This app was created for educational purposes and we used all our common practices just like we do when creating commercial apps. Read more about AGILE on [our blog](https://yalantis.com/blog/we-just-launched-pixpic-a-photo-editing-app-built-by-our-ios-interns/).

We followed gitflow approach and merge requests in order to check the code. This approach let our senior developers share their valuable expertise with interns. 
Delivering builds for testing was automated through Continuous Integration Server. One of our mentors pretended to be a customer who came to us with an idea for an app. While we were working on the app, he regularly received new builds - in time and after each sprint. Guys went the whole way from an idea and basic design concept  to generating provisioning profiles and certificates and deploying the final build to iTunes Connect.
Here’s where you can check out [the app itself](https://itunes.apple.com/us/app/pixpic-pixel-stickers-kit/id1132190990?mt=8).

We improved the MVC architecture offered by Apple by providing special Router class for every View Controller to decrease coupling and separate different parts of the logic inside of the app. All dependency injections and data transferring go through Routers.

## Technology Stack

Continuous Integration - Xcode Server
Crashlog - Crashlitics
Build delivery - Fabric
Database - Parse local storage
Serverside - Parse server
Authorization service - FBSDK

## Used libraries

**Toast** - An Objective-C category that adds toast notifications to the UIView object class.

**SVPullToRefresh** - These UIScrollView categories make it easy to add pull-to-refresh and infinite scrolling functionalities to any UIScrollView (or any of its subclasses).

**DateTools** - A dropdown iOS notification view 

**MBProgressHUD** - An easy to use iOS progress indicator that includes both fixed and indeterminate styles.

License
----------------

The MIT License (MIT)

Copyright (c) 2015 Yalantis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
