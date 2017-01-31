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
import RxSwift

struct Post: Mappable {
    var id = -1
    var title = ""
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
    }
    
}

struct GetAllPostsRequest: KonexRequest {
    let path: String = "https://jsonplaceholder.typicode.com/posts"
}

struct CreatePostRequest: KonexRequest {
    var path: String = "https://jsonplaceholder.typicode.com/posts"
    var parameters: [String : Any]? {
        return [
            "title": "Es una prueba",
            "body": "Que sale bien?"
        ]
    }
    var method: Konex.HTTPMethod = .post
}

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = KonexClient()
        
        client.plugins.append(KonexComponent.NetworkLogger())
        
        let request = GetAllPostsRequest()
        
        client
            .requestArray(of: Post.self, request: request)
            .subscribe(
                onNext: { (posts: [Post]) in
                    
                },
                onError: { (error: Error) in
                    
                }
            )
            .addDisposableTo(disposeBag)
        
        client
            .requestObject(ofType: Post.self, request: CreatePostRequest())
            .subscribe(
                onNext: { post in
                    
                },
                onError: { error in
                    
                }
            )
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
