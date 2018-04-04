//
//  GraphQL.swift
//  iGithub
//
//  Created by Chan Hocheung on 12/06/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation

class GraphQL {
    static func query(_ token: GitHubAPI) -> [String: Any]? {
        switch token {
        case let .repository(repo):
            return [
                "query": repositoryQuery,
                "variables": ["owner": repo.owner, "name": repo.name],
            ]

        case let .repositories(login, type, after):

            var variables: [String: Any] = [
                "login": login,
                "first": 30,
                "orderBy": ["field": "PUSHED_AT", "direction": "DESC"],
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": type == .user ? userRepositoriesQuery : organizationRepositoriesQuery,
                "variables": variables,
            ]

        case let .starredRepos(user, after):

            var variables: [String: Any] = [
                "login": user,
                "first": 30,
                "orderBy": ["field": "STARRED_AT", "direction": "DESC"],
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": starredRepositoriesQuery,
                "variables": variables,
            ]

        case let .subscribedRepos(user, after):
            var variables: [String: Any] = [
                "login": user,
                "first": 30,
                "orderBy": ["field": "UPDATED_AT", "direction": "DESC"],
            ]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": watchingQuery,
                "variables": variables,
            ]

        case let .searchRepositories(query, after):
            var variables: [String: Any] = ["query": query]
            if let after = after {
                variables["after"] = after
            }

            return [
                "query": searchRepositoriesQuery,
                "variables": variables,
            ]

        default:
            return nil
        }
    }
}
