<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-ready-orange.svg"></a>
<a href="https://github.com/d-date/OAuth2Client/blob/master/LICENSE"><img alt="MIT License" src="http://img.shields.io/badge/license-MIT-blue.svg"/></a>

# OAuth2Client

Lightweight OAuth 2.0 Client with PKCE (Proof key for Code Exchange: see [RFC 7636](https://tools.ietf.org/html/rfc7636))

## Usage

### Sign in

```swift
OAuth2Client().signIn(request: request) 
  .receive(on: yourQueue)
  .sink(receiveCompletion: { (completion) in
    
  }, receiveValue: { (credential) in
    credential.save()
  })
```

### Load Access Token

```swift
Credential.load()
```

### Refresh

```swift
OAuth2Client().refresh(request: request) 
.receive(on: yourQueue)
.sink(receiveCompletion: { (completion) in

}, receiveValue: { (credential) in
credential.save()
})
```

### Sign Out
Removing cache on WebKit, and showing new auth screen.

```swift
OAuth2Client().signOut(request: request) 
  .receive(on: yourQueue)
  .sink(receiveCompletion: { (completion) in

  }, receiveValue: { (credential) in
    credential.save()
  })
```

## Features

- [x] Supporting OAuth 2.0 with PKCE
- [x] Publish / refresh access token
- [x] Combine interface

## General notes for OAuth 2.0
- Make sure setting callback url scheme on your setting

## Supported platforms

- macOS v11.0 and later
- iOS / iPadOS v14.0 and later

## Installation

Only support via Swift package manager installation.

### Swift Package Manager

```swift
dependencies: [
  .package(url: "https://github.com/d-date/OAuth2Client.git", from: "0.1.0")
]
```
