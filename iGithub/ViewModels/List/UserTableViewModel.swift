//
//  UserTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class UserTableViewModel: BaseTableViewModel<User> {
    var token: GitHubAPI

    init(repo: Repository) {
        token = .repositoryContributors(repo: repo.nameWithOwner!, page: 1)
        super.init()
    }

    init(organization: User) {
        token = .organizationMembers(org: organization.login!, page: 1)
        super.init()
    }

    init(followedBy user: User) {
        token = .followedBy(user: user.login!, page: 1)
        super.init()
    }

    init(followersOf user: User) {
        token = .followersOf(user: user.login!, page: 1)
        super.init()
    }

    func updateToken() {
        switch token {
        case let .repositoryContributors(repo, _):
            token = .repositoryContributors(repo: repo, page: page)
        case let .organizationMembers(org, _):
            token = .organizationMembers(org: org, page: page)
        case let .followedBy(user, _):
            token = .followedBy(user: user, page: page)
        case let .followersOf(user, _):
            token = .followersOf(user: user, page: page)
        default:
            break
        }
    }

    override func fetchData() {
        updateToken()

        GitHubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = $0.response?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    if let newUsers = Mapper<User>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newUsers
                        } else {
                            self.dataSource.value.append(contentsOf: newUsers)
                        }

                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .addDisposableTo(disposeBag)
    }
}
