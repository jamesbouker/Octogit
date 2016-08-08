//
//  IssueTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueTableViewController: BaseTableViewController {

    var viewModel: IssueTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx_itemsWithCellIdentifier("IssueCell", cellType: IssueCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(IssueCell.self, forCellReuseIdentifier: "IssueCell")
        
        viewModel.fetchData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let issueVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IssueVC") as! IssueViewController
        issueVC.viewModel = viewModel.viewModelForIndex(indexPath.row)
        self.navigationController?.pushViewController(issueVC, animated: true)
    }

}