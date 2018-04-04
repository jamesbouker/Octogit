//
//  UserTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxSwift
import UIKit

class UserTableViewController: BaseTableViewController {
    var viewModel: UserTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshing()

                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .do(onNext: { [unowned self] in
                    if $0.count <= 0 {
                        self.show(statusType: .empty)
                    } else {
                        self.hide(statusType: .empty)
                    }
                })
                .drive(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) { _, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)

            viewModel.error.asDriver()
                .filter {
                    $0 != nil
                }
                .drive(onNext: { [unowned self] in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.tableView.refreshFooter?.endRefreshing()
                    MessageManager.show(error: $0!)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")

        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))

        tableView.refreshHeader?.beginRefreshing()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = viewModel.dataSource.value[indexPath.row]
        switch entity.type! {
        case .user:
            let userVC = UserViewController.instantiateFromStoryboard()
            userVC.viewModel = UserViewModel(entity)
            navigationController?.pushViewController(userVC, animated: true)
        case .organization:
            let orgVC = OrganizationViewController.instantiateFromStoryboard()
            orgVC.viewModel = OrganizationViewModel(entity)
            navigationController?.pushViewController(orgVC, animated: true)
        }
    }
}
