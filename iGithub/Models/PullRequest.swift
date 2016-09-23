//
//  PullRequest.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum PullRequestState : String {
    case open = "open"
    case closed = "closed"
    case all = "all"
}

class PullRequest : BaseModel {
    
    var id: Int?
    var number: Int?
    var title: String?
    var body: String?
    var isMerged: Bool?
    var state: PullRequestState?
    var assignees: [User]?
    
    override func mapping(map: Map) {
        id       <- map["id"]
        number   <- map["number"]
        title    <- map["title"]
        body     <- map["body"]
        isMerged <- map["merged"]
        state    <- map["state"]
    }
}
