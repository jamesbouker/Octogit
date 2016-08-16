//
//  GithubAPI.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya

enum SearchOrder: String {
    case Asc = "asc"
    case Desc = "desc"
}

enum RepositoriesSearchSort: String {
    case Default = ""
    case Forks = "forks"
    case Stars = "stars"
    case Updated = "updated"
}

enum UsersSearchSort: String {
    case Default = ""
    case Followers = "followers"
    case Joined = "joined"
    case Repositories = "repositories"
}

enum GithubAPI {
    case GetARepository(repo: String)
    case GetContents(repo: String, path: String)
    case OAuthUser(accessToken: String)
    case Members(org: String)
    case Organization(org: String)
    case Organizations(user: String)
    case OrganizationEvents(org: String)
    case OrganizationRepos(org: String)
    case ReceivedEvents(user: String)
    case RepositoryContributors(repo: String)
    case RepositoryEvents(repo: String)
    case RepositoryIssues(repo: String)
    case RepositoryPullRequests(repo: String)
    case SearchRepositories(q: String, sort: RepositoriesSearchSort, order: SearchOrder)
    case SearchUsers(q: String, sort: UsersSearchSort, order: SearchOrder)
    case StarredRepos(user: String)
    case User(user: String)
    case UserEvents(user: String)
    case UserRepos(user: String)
}

extension GithubAPI: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .GetARepository(let repo):
            return "/repos/\(repo)"
        case .GetContents(let repo, let path):
            return "/repos/\(repo)/contents/\(path)"
        case .Members(let org):
            return "/orgs/\(org)/members"
        case .OAuthUser(_):
            return "/user"
        case .Organization(let org):
            return "/orgs/\(org)"
        case .Organizations(let user):
            return "/users/\(user)/orgs"
        case .OrganizationEvents(let org):
            return "/orgs/\(org)/events"
        case .OrganizationRepos(let org):
            return "/orgs/\(org)/repos"
        case .ReceivedEvents(let user):
            return "/users/\(user)/received_events"
        case .RepositoryContributors(let repo):
            return "/repos/\(repo)/contributors"
        case .RepositoryEvents(let repo):
            return "/repos/\(repo)/events"
        case .RepositoryIssues(let repo):
            return "/repos/\(repo)/issues"
        case .RepositoryPullRequests(let repo):
            return "/repos/\(repo)/pulls"
        case .SearchRepositories(_, _, _):
            return "/search/repositories"
        case .SearchUsers(_, _, _):
            return "/search/users"
        case .StarredRepos(let user):
            return "/users/\(user)/starred"
        case .User(let user):
            return "/users/\(user)"
        case .UserEvents(let user):
            return "/users/\(user)/events"
        case .UserRepos(let user):
            return "/users/\(user)/repos"
        }
    }
    var method: RxMoya.Method {
        switch self {
        default:
            return .GET
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .OAuthUser(let accessToken):
            return ["access_token": accessToken]
        case .SearchRepositories(let q, let sort, let order):
            return ["q": q, "sort": sort.rawValue, "order": order.rawValue]
        case .SearchUsers(let q, let sort, let order):
            return ["q": q, "sort": sort.rawValue, "order": order.rawValue]
        default:
            return nil
        }
    }
    var sampleData: NSData {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        }
    }
    var multipartBody: [RxMoya.MultipartFormData]? {
        switch self {
        default:
            return nil
        }
    }
}


private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}