<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-ready-orange.svg"></a>
<a href="https://github.com/d-date/OAuth2Client/blob/master/LICENSE"><img alt="MIT License" src="http://img.shields.io/badge/license-MIT-blue.svg"/></a>

# OAuth2Client

Lightweight OAuth 2.0 Client with PKCE (Proof key for Code Exchange: see [RFC 7636](https://tools.ietf.org/html/rfc7636))

## Usage

### Sign in

```swift
  let credential = await OAuth2Client().signIn(request: request) 
```

### Refresh

```swift
let credential = await OAuth2Client().refresh(request: request) 
```

### Sign Out
Removing cache on WebKit, and show new screen to authenticate.

```swift
let credential = await OAuth2Client().signOut(request: request) 
```

## Features

- [x] Supporting OAuth 2.0 with PKCE
- [x] Publish / refresh access token
- [x] Swift Concurrency interface

Note: If you want to use Combine interface, use 0.x version

## General notes for OAuth 2.0
- Make sure setting callback url scheme on your setting

## Supported platforms

- macOS v12.0 or later
- iOS / iPadOS v15.0 or later

Note: After Swift Concurrency is backported, iOS 13.0 / macOS 10.15 can be used

## Installation

### Swift Package Manager

```swift
dependencies: [
  .package(url: "https://github.com/d-date/OAuth2Client.git", .branch("concurrency"))
]
```
