# UPlace

UPlace is an iOS application that connects people in space-defined communities.

  - It is still under development
  - Screenshots below shows you what have been implemented
  - Feel free to contribute to it :)


 <img src="/Screenshots/Launch_image.png" alt="Launch Screen" width="300" height="534" />
 <img src="/Screenshots/IMG_0209.PNG" alt="Feed" width="300" height="534" />
 <img src="/Screenshots/IMG_0214.PNG" alt="New Post" width="300" height="534" />
 <img src="/Screenshots/IMG_0213.PNG" alt="Discover" width="300" height="534" />
 <img src="/Screenshots/IMG_0211.PNG" alt="Side Menu" width="300" height="534" />
 <img src="/Screenshots/IMG_0249.PNG" alt="Profile" width="300" height="534" />

### Version
0.4.2

### Tech

UPlace uses BaaS [FatFractal] for backend services

UPlace uses [Google Places API] to retrieve place/location information

UPlace uses a number of open source projects:

* [SVProgressHUD] - A clean and lightweight progress HUD for iOS app
* [DZNSegmentedControl] - A drop-in replacement for UISegmentedControl used on user profile view
* [RESideMenu] - iOS 7/8 style side menu with parallax effect
* [FTGooglePlacesAPI] - iOS library for querying Google Places API using simple block-based interface
* [XHImageViewer] - A simple image viewer
* [AFNetworking] - A delightful iOS and OS X networking framework
* [GOPlacesAutocomplete] - Lightweight Objective-C wrappers around Google Places Autocomplete and Details APIs

### Getting started

Clone the project.

[Create A New API] for your backend and define a baseurl in AppDelegate.m:

```objectivec

#define FatFractalBaseURL @"http://<YOUR APP DOMAIN>.fatfractal.com/<YOUR APP NAME>"

```

Obtain a [Google Places API] key and define in AppDelegate.m:

```objectivec

#define GoogleAPIKey @"YOUR_GOOGLE_API_KEY"

```

That's it!

### Todo's

 - Visualize a location with a map
 - Recommendations for nearby places
 - Add pull-to-refresh
 - Image picker that lets users pick images from album
 - Notification view
 - Post detail/comment view
 - User registration
 - Push notification
 - Thumbnail images (should load thumbnails first instead of original images)
 - Comment model
 - Like model
 - etc.

### Contact

Maintainer: [Wes Zheng](http://github.com/wz366)

Feel free to contact me if needed!

License
----
UPlace is available under the MIT license. See the LICENSE file for more info.


[SVProgressHUD]: https://github.com/TransitApp/SVProgressHUD
[DZNSegmentedControl]: https://github.com/dzenbot/DZNSegmentedControl
[RESideMenu]: https://github.com/romaonthego/RESideMenu
[FTGooglePlacesAPI]: https://github.com/FuerteInternational/FTGooglePlacesAPI
[XHImageViewer]: https://github.com/JackTeam/XHImageViewer
[AFNetworking]: https://github.com/AFNetworking/AFNetworking
[GOPlacesAutocomplete]: https://github.com/henrinormak/GOPlacesAutocomplete
[FatFractal]: http://fatfractal.com/
[Google Places API]: https://developers.google.com/places
[Create A New API]: http://fatfractal.com/v2/documentation/#document-noserver-getting-started
