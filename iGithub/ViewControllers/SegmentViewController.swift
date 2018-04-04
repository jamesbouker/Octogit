//
//  SegmentViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/9/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Pageboy
import TwicketSegmentedControl

class SegmentViewController: UIViewController {
    var titles: [String]
    var viewControllers: [UIViewController]
    let pageViewController = PageboyViewController()
    let segmentedControl = TwicketSegmentedControl()
    var initialPage: Int

    init(viewControllers: [UIViewController], titles: [String], initialPage: Int = 0) {
        assert(viewControllers.count == titles.count)

        self.titles = titles
        self.viewControllers = viewControllers
        segmentedControl.setSegmentItems(titles)

        self.initialPage = initialPage

        super.init(nibName: nil, bundle: nil)

        addChildViewController(pageViewController)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.dataSource = self
        pageViewController.delegate = self
        segmentedControl.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        if #available(iOS 11.0, *) {
            // do nothing
        } else {
            edgesForExtendedLayout = []
        }

        configureSegmentedControl()
    }

    func configureSegmentedControl() {
        let contentView = pageViewController.view!

        let line = UIView()
        line.backgroundColor = UIColor(netHex: 0xB2B2B2)

        view.addSubviews([contentView, line, segmentedControl])

        var topConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            topConstraint = contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        } else {
            topConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topConstraint,

            line.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            line.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            line.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor),

            segmentedControl.heightAnchor.constraint(equalToConstant: TwicketSegmentedControl.height),
            segmentedControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension SegmentViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        pageViewController.scrollToPage(.at(index: segmentIndex), animated: true)
    }
}

extension SegmentViewController: PageboyViewControllerDataSource {
    public func numberOfViewControllers(in _: Pageboy.PageboyViewController) -> Int {
        return viewControllers.count
    }

    public func viewController(for _: Pageboy.PageboyViewController,
                               at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    public func defaultPage(for _: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        return Pageboy.PageboyViewController.Page.at(index: initialPage)
    }
}

extension SegmentViewController: PageboyViewControllerDelegate {
    func pageboyViewController(_: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction _: PageboyViewController.NavigationDirection,
                               animated _: Bool) {
        segmentedControl.move(to: index)
    }
}
