//
//  MessageManager.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Moya
import SwiftMessages

class MessageManager {
    class func show(error: Swift.Error) {
        guard let e = error as? MoyaError else {
            return
        }

        var body: String

        switch e {
        case .jsonMapping, .imageMapping, .stringMapping:
            body = "Data error"
        case let .statusCode(response):
            body = "\(response.statusCode) error"
        case let .underlying(nsError as NSError, _):
            switch nsError.code {
            case NSURLErrorTimedOut:
                body = "Request timeout."
            case NSURLErrorNetworkConnectionLost:
                body = "The network connection is lost."
            default:
                body = nsError.localizedDescription
            }
        default: body = ""
        }
        MessageManager.showMessage(title: "", body: body, type: .error)
    }

    class func showMessage(title: String, body: String, type: Theme) {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        config.interactiveHide = true

        let messageView: MessageView = try! SwiftMessages.viewFromNib()
        messageView.configureTheme(type)
        messageView.configureContent(title: title, body: body)
        messageView.button?.isHidden = true
        messageView.titleLabel?.isHidden = title.count <= 0

        SwiftMessages.show(config: config, view: messageView)
    }
}
