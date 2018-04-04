//
//  OrganizationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxSwift
import UIKit

class OrganizationViewController: BaseTableViewController {
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    let statusCell = StatusCell(name: "organization")

    var viewModel: OrganizationViewModel! {
        didSet {
            viewModel.user.asDriver()
                .drive(onNext: { [unowned self] org in
                    self.tableView.reloadData()

                    self.configureHeader(org: org)
                    self.sizeHeaderToFit(tableView: self.tableView)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }

    class func instantiateFromStoryboard() -> OrganizationViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrganizationViewController") as! OrganizationViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        viewModel.fetchUser()
    }

    func configureHeader(org: User) {
        avatarView.setAvatar(with: org.avatarURL)
        descLabel.text = org.orgDescription

        if let name = org.name?.trimmingCharacters(in: .whitespaces)
            , name.count > 0 {
            nameLabel.text = name
        } else {
            nameLabel.text = org.login
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsIn(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.userLoaded else {
            return statusCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.textColor = UIColor(netHex: 0x333333)

        switch viewModel.sectionTypes[indexPath.section] {
        case .vcards:
            switch viewModel.vcardDetails[indexPath.row] {
            case .company:
                cell.textLabel?.attributedText = Octicon.organization.iconString(" \(viewModel.user.value.company!)", iconSize: 18, iconColor: .lightGray)
            case .location:
                cell.textLabel?.attributedText = Octicon.location.iconString(" \(viewModel.user.value.location!)", iconSize: 18, iconColor: .lightGray)
            case .email:
                cell.textLabel?.attributedText = Octicon.mail.iconString(" \(viewModel.user.value.email!)", iconSize: 18, iconColor: .lightGray)
            case .blog:
                cell.textLabel?.attributedText = Octicon.link.iconString(" \(viewModel.user.value.blog!)", iconSize: 18, iconColor: .lightGray)
                cell.accessoryType = .disclosureIndicator
            }

            return cell

        case .general:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = ["Public activity", "Repositories", "Members"][indexPath.row]
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.rss.iconString(" Public activity", iconSize: 18, iconColor: .lightGray)
            case 1:
                cell.textLabel?.attributedText = Octicon.repo.iconString(" Repositories", iconSize: 18, iconColor: .lightGray)
            case 2:
                cell.textLabel?.attributedText = Octicon.organization.iconString(" Members", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }

            return cell

        default:
            return cell
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.sectionTypes[indexPath.section] {
        case .vcards:
            if viewModel.vcardDetails[indexPath.row] == .blog {
                navigationController?.pushViewController(URLRouter.viewController(forURL: viewModel.user.value.blog!), animated: true)
            }
        case .general:
            switch indexPath.row {
            case 0:
                let eventTVC = EventTableViewController()
                eventTVC.viewModel = EventTableViewModel(org: viewModel.user.value)
                navigationController?.pushViewController(eventTVC, animated: true)
            case 1:
                let repositoryTVC = RepositoryTableViewController()
                repositoryTVC.viewModel = RepositoryTableViewModel(login: viewModel.user.value.login, type: .organization)
                navigationController?.pushViewController(repositoryTVC, animated: true)
            case 2:
                let userTVC = UserTableViewController()
                userTVC.viewModel = UserTableViewModel(organization: viewModel.user.value)
                navigationController?.pushViewController(userTVC, animated: true)
            default:
                break
            }
        default: break
        }
    }
}
