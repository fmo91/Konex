# Konex

[![CI Status](http://img.shields.io/travis/fmo91/Konex.svg?style=flat)](https://travis-ci.org/fmo91/Konex)
[![Version](https://img.shields.io/cocoapods/v/Konex.svg?style=flat)](http://cocoapods.org/pods/Konex)
[![License](https://img.shields.io/cocoapods/l/Konex.svg?style=flat)](http://cocoapods.org/pods/Konex)
[![Platform](https://img.shields.io/cocoapods/p/Konex.svg?style=flat)](http://cocoapods.org/pods/Konex)

## Introduction

Konex is a lightweight protocol-oriented networking library written in swift that can be easily extended or modified. It enforces a networking layer organization by forces to implement each request in a separate object. 
Konex can optionally parse responses to json objects.

## Brief practical example

At the core of the Konex library there is the `KonexRequest` protocol. So, the first you have to do is implement that protocol in a struct or a class.

```swift
struct GetAllPostsRequest: KonexRequest {
	let path = "https://jsonplaceholder.typicode.com/posts/"
    let method = .post
}
```

We need a Post class that can be written like this:

```swift
import ObjectMapper

struct Post: KonexJSONDecodable {
    var id: Int?
    var title: String?
    
    init() {}
    
    static func instantiate(withJSON json: [String : Any]) -> Post? {
        var post = Post()
        
        post.id = json["id"] as? Int
        post.title = json["title"] as? String
        
        return post
    }
}
```

It's important for our purposes that the Post class implements `KonexJSONDecodable` protocol.
Once you have the model and the request modelled, we are in conditions of dispatching that request and getting the response.

The class that is responsible for dispatching requests is `KonexClient`. It can be used as is, so you can instantiate it and start using in wherever you want.

```swift
let client = KonexClient()

let request = GetAllPostsRequest()

client.requestArray(of: Post.self,
    request: request,
    onSuccess: { (posts: [Post]) in
        // You can do whatever you want with your posts!
    },
    onError: { (error: Error) in
        // You should handle this...
    }
)
```

And that's all! You can have base requests, if you like object oriented programming. This and more is going to be extended in the following sections.

## Creating requests

You can model your requests in either a protocol-oriented fashion, or in a more object oriented one.

**Protocol oriented request**: Konex provides a `KonexRequest` protocol that is required for your Request to implement in order to be dispatched by a `KonexClient`.
`KonexRequest` is a very important part of the KonexLibrary. A `KonexRequest` defines the following properties that you can implement in your requests:

* **path**: A string that represents the request URL. **This is the only required property**.
* **method**: An enum value that represents the request HTTP method. It is of `Konex.HTTPMethod` type. Defaults to `.get`
* **parameters**: A JSON object that will be added to the request URL in case of `.get` request or to the http body in any other case. Defaults to `nil`
* **headers**: The request headers. Defaults to `nil`

In addition, `KonexRequest` also lets you add Konex extension components that are exclusive to your request. Konex extension components will be explained later in this guide, but for the moment, there are them:

* **requestPlugins**:  It's an array of `KonexPlugin` objects. Defaults to [].
* **requestResponseProcessors**: It's an array of `KonexResponseProcessor` objects. Defaults to [].
* **requestResponseValidators**: It's an array of `KonexResponseValidator` objects. Defaults to [].

**Object oriented request**: In addition to the protocol oriented way, Konex allows you to model your requests in a more object oriented way. Konex defines a `KonexBasicRequest` class, that implements `KonexRequest` protocol and is totally open to subclass. **It can't be used as is. It's kind of an abstract class. MUST SUBCLASS**.

```swift
open class KonexBasicRequest: KonexRequest {
    open var requestPlugins: [KonexPlugin] { return [] }
    open var requestResponseProcessors: [KonexResponseProcessor] { return [] } 
    open var requestResponseValidators: [KonexResponseValidator] { return [] }
    
    open var path: String { return "" }
    open var method: Konex.HTTPMethod { return .get }
    open var parameters: [String : Any]? { return [:] }
    open var headers: [String : String]? { return [:] }
    
    public init() {}
}
```

That simple. You can subclass it and define your Base Request or something like that. You can also have an AuthenticatedRequest or something like that. You are free to create your requests hierarchy as you want.

## Dispatching requests

To dispatch `KonexRequest` objects, you need a `KonexClient`. `KonexClient` relies on URLSession to dispatch requests. So the first step is creating a `KonexClient`. This can be done using its initializer:

```swift
let client = KonexClient()
```

This initalizes its `URLSession` attribute member to `URLSession.default`. If you want, you can inject another `URLSession` using this initializer:

```swift
let client = KonexClient(urlSession: anotherSession)
```

Once you have a `KonexClient`, you can use it to dispatch `KonexRequest` objects.

`KonexClient` defines three methods to do so:

```swift
open func request(
	request: KonexRequest, 
    plugins localPlugins: [KonexPlugin] = [], 
    responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], 
    responseValidators localResponseValidators: [KonexResponseValidator] = [], 
    onSuccess: @escaping (Any) -> Void, 
    onError: @escaping (Error) -> Void) -> URLSessionDataTask?
```

`request` method defines the core logic to perform requests. It dispatches your requests and you pass two closures to it, one for the success case, and another one for the error case.

`KonexClient` can also parse the responses so you can get the final version of the data. There are two methods. `requestObject` and `requestArray`, both of those are similar.

```swift
open func requestObject<T:Mappable>(ofType type: T.Type, 
	request: KonexRequest, 
    plugins localPlugins: [KonexPlugin] = [], 
    responseProcessors localResponseProcessors: [KonexResponseProcessor] = [],
    responseValidators localResponseValidators: [KonexResponseValidator] = [],
    onSuccess: @escaping (T) -> Void, 
    onError: @escaping (Error) -> Void) -> URLSessionDataTask?

open func requestArray<T: Mappable>(of type: T.Type, 
	request: KonexRequest, 
    plugins localPlugins: [KonexPlugin] = [], 
    responseProcessors localResponseProcessors: [KonexResponseProcessor] = [],
    responseValidators localResponseValidators: [KonexResponseValidator] = [], 
    onSuccess: @escaping ([T]) -> Void, 
    onError: @escaping (Error) -> Void) -> URLSessionDataTask?
```

Finally, `KonexClient` is an open class, and so its member methods, so you can customize it as your will.

## Extending Konex

`Konex` defines three protocols that you can use in order to extend your requests dispatching logic. 

* **KonexPlugin**: It defines two methods: `didSendRequest` and `didReceiveResponse`. An example of this could be a Network logger, or a Network indicator handler.
* **KonexResponseProcessor**: Defines `func process(response: Any) -> Any`, that allows you to create functional pipes to process the response that comes after dispatching a request.
* **KonexResponseValidator**: Defines `func validate(response: Any) throws`

Konex components can be added at three different levels:

* **The client level**: `KonexClient` exposes properties called `plugins`, `responseProcessors` and `responseValidators` where you can append your extension components.
* **The request level**: `KonexRequest` defines three properties, `requestPlugins`, `requestResponseProcessors` and  `requestResponseValidators`.
* **The method level**: `KonexClient` methods accepts extension components within their arguments

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Konex is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Konex"
```

## Author

fmo91, ortizfernandomartin@gmail.com

## License

Konex is available under the MIT license. See the LICENSE file for more info.
