# ecosort-ios
iOS Application for waste classification

# Description
EcoSort – An AI-Powered Waste Classification Mobile App

# Getting Started
## Prerequisites
* iOS version >= 17.6
* XCode Version >= 16.1
* Swift Version >= 6
* OS MacOS >= 15

## Dependencies
- [Swift Factory](https://github.com/hmlongco/Factory)
- [TFLite](https://github.com/tensorflow/tensorflow) (Note: This is generated using bazel, and packaged for SPM)

## Installation
1. In `<project_root>/Debug.xcconfig` and `<project_root>/Release.xcconfig`, you need to configure the following:
```
MODEL_RELEASE_API_KEY # Where the model is downloaded from 
API_REQ_KEY # API Key for accessing the endpoint
BASE_URL # API Endpoint
BASE_URL_PROTOCOL # Base url protocol http/https
WEBSOCKET_PROTOCOL # Websocket protocol
```
2. Install XCode >= 16.1 from [apple downloads or App Store](https://developer.apple.com.downloads)
3. Open the project using XCode after downloading
4. CMD + R to run the application