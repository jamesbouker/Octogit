//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import WebKit

class IssueViewController: UIViewController {
    let indicator = LoadingIndicator()
    let webView = WKWebView()

    let disposeBag = DisposeBag()
    var viewModel: IssueViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(netHex: 0xEFEFF4)
        view.addSubview(webView)

        show(indicator: indicator, onView: webView)

        navigationItem.title = "#\(viewModel.number)"

        viewModel.html.asDriver()
            .flatMap { Driver.from(optional: $0) }
            .drive(onNext: { [unowned self] in
                self.webView.loadHTMLString($0, baseURL: Bundle.main.resourceURL)
                self.indicator.removeFromSuperview()
            })
            .addDisposableTo(disposeBag)

        viewModel.fetchData()
    }
}

extension IssueViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.isFileURL {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)

        let vc = URLRouter.viewController(forURL: url)
        navigationController?.pushViewController(vc, animated: true)
    }
}
