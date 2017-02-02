//
//  ViewController.swift
//  Konex
//
//  Created by fmo91 on 01/30/2017.
//  Copyright (c) 2017 fmo91. All rights reserved.
//

import UIKit
import ObjectMapper
import Konex

struct Post: KonexJSONDecodable {
    var id = -1
    var title = ""
    
    init() {}
    
    init?(map: Map) {
        
    }
    
    static func instantiate(withJSON json: [String : Any]) -> Post? {
        var post = Post()
        
        post.id = (json["id"] as? Int) ?? -1
        post.title = (json["title"] as? String) ?? ""
        
        return post
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
    }
    
}

struct GetAllPostsRequest: KonexRequest {
    let path: String = "https://jsonplaceholder.typicode.com/posts"
}

struct GetPostByIDRequest: KonexRequest {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    var path: String { return "https://jsonplaceholder.typicode.com/posts/\(id)" }
    
    var method: Konex.HTTPMethod = .get
}

class CreatePostRequest: KonexBaseRequest {
    override var path: String {
        return "https://jsonplaceholder.typicode.com/posts/"
    }
    override var method: Konex.HTTPMethod {
        return .post
    }
    override var parameters: [String : Any]? {
        return [
            "title": "Something good"
        ]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = KonexClient()
        
        let request = CreatePostRequest()
        
        client
            .requestObject(ofType: Post.self,
                request: request,
                onSuccess: { post in
                    print("Received a post with title: \(post.title)")
                },
                onError: { error in
                    print("Something went wrong.")
                }
            )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

