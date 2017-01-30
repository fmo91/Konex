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
import RxObjectMapper
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

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GetAllPostsRequest()
            .dispatch()
            .mapArray(type: Post.self)
            .map { $0.map { $0.title } }
            .subscribe(
                onNext: { (titles: [String]) in
                    print(titles)
                },
                onError: { (error: Error) in
                    print("An error ocurred")
                }
            )
            .addDisposableTo(disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

