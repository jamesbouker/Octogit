//
//  GitHubAPI.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift

// MARK: - OAuth Configuration

struct OAuthConfiguration {
    static let callbackMark = "iGithub"
    static let clientID = "638bff0d62dacd915554"
    static let clientSecret = "006e5bd102210c78981af47bbe347318cf55081b"
    static let scopes = ["user", "repo"]
    static let note = "Octogit: Application"
    static let noteURL = "https://github.com/chanhx/Octogit"
    static var accessToken: String?

    static var authorizationURL: URL? {
        return GitHubProvider
            .endpoint(.authorize)
            .urlRequest?
            .url
    }
}

// MARK: - Provider setup

let GitHubProvider = RxMoyaProvider<GitHubAPI>()

// MARK: - Provider support

enum RepositoriesSearchSort: String, CustomStringConvertible {
    case bestMatch = ""
    case forks
    case stars
    case updated

    var description: String {
        switch self {
        case .bestMatch:
            return "Best match"
        case .forks:
            return "Most forks"
        case .stars:
            return "Most stars"
        case .updated:
            return "Recently updated"
        }
    }
}

enum UsersSearchSort: String, CustomStringConvertible {
    case bestMatch = ""
    case followers
    case joined
    case repositories

    var description: String {
        switch self {
        case .bestMatch:
            return "Best match"
        case .followers:
            return "Most followers"
        case .repositories:
            return "Most repositories"
        case .joined:
            return "Recently joined"
        }
    }
}

enum TrendingTime: String {
    case today = "daily"
    case thisWeek = "weekly"
    case thisMonth = "monthly"
}

enum RepositoryOwnerType {
    case user
    case organization
}

enum GitHubAPI {

    // MARK: Web API

    case authorize
    case accessToken(code: String)
    case trending(since: TrendingTime, language: String, type: TrendingType)

    // MARK: Branch

    case branches(repo: String, page: Int)

    // MARK: File

    case getABlob(repo: String, sha: String)
    case getContents(repo: String, path: String, ref: String)
    case getHTMLContents(repo: String, path: String, ref: String)
    case getTheREADME(repo: String, ref: String)
    case pullRequestFiles(repo: String, number: Int, page: Int)

    // MARK: Comment

    case issueComments(repo: String, number: Int, page: Int)
    case commitComments(repo: String, sha: String, page: Int)
    case gistComments(gistID: String, page: Int)

    // MARK: User

    case oAuthUser(accessToken: String)
    case user(user: String)

    case organization(org: String)
    case organizations(user: String)
    case organizationMembers(org: String, page: Int)
    case repositoryContributors(repo: String, page: Int)

    case followedBy(user: String, page: Int)
    case followersOf(user: String, page: Int)

    case isFollowing(user: String)
    case follow(user: String)
    case unfollow(user: String)

    // MARK: Event

    case receivedEvents(user: String, page: Int)
    case userEvents(user: String, page: Int)
    case organizationEvents(org: String, page: Int)
    case repositoryEvents(repo: String, page: Int)

    // MARK: Issue & Pull Request

    case issues(repo: String, page: Int, state: IssueState)
    case pullRequests(repo: String, page: Int, state: IssueState)

    case issue(owner: String, name: String, number: Int)
    case pullRequest(owner: String, name: String, number: Int)

    case authenticatedUserIssues(page: Int, state: IssueState)

    // MARK: Commit

    case repositoryCommits(repo: String, sha: String, page: Int)
    case pullRequestCommits(repo: String, number: Int, page: Int)
    case commit(repo: String, sha: String)

    // MARK: Search

    case searchRepositories(query: String, after: String?)
    case searchUsers(q: String, sort: UsersSearchSort, page: Int)

    // MARK: Repository

    case repositories(login: String, type: RepositoryOwnerType, after: String?)
    case starredRepos(user: String, after: String?)
    case subscribedRepos(user: String, after: String?)
    case repository(owner: String, name: String)

    case star(repo: String)
    case unstar(repo: String)

    // MARK: Release

    case releases(repo: String, page: Int)

    // MARK: Gist

    case userGists(user: String, page: Int)
    case starredGists(page: Int)
}

extension GitHubAPI: TargetType {
    var headers: [String: String]? {
        var headers = ["Content-type": "application/json"]

        if let token = AccountManager.token {
            headers["Authorization"] = "token \(token)"
        }

        switch self {
        case .getABlob:
            headers["Accept"] = MediaType.Raw
        case .getHTMLContents, .getTheREADME:
            headers["Accept"] = MediaType.HTML
        case .issue, .pullRequest, .issues, .pullRequests, .issueComments:
            headers["Accept"] = MediaType.HTMLAndJSON
        case .gistComments, .commitComments:
            headers["Accept"] = MediaType.TextAndJSON
        default:
            break
        }

        return headers
    }

    var baseURL: URL {
        switch self {
        case .authorize,
             .accessToken(code: _),
             .trending(since: _, language: _, type: _):

            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }

    var path: String {
        switch self {
            // MAKR: Web API

        case .authorize:
            return "/login/oauth/authorize"
        case .accessToken:
            return "/login/oauth/access_token"
        case let .trending(_, _, type):
            switch type {
            case .repositories:
                return "/trending"
            case .users:
                return "/trending/developers"
            }

            // MARK: Branch

        case let .branches(repo, _):
            return "repos/\(repo)/branches"

            // MARK: File

        case let .getABlob(repo, sha):
            return "/repos/\(repo)/git/blobs/\(sha)"
        case let .getContents(repo, path, _):
            return "/repos/\(repo)/contents/\(path)"
        case let .getHTMLContents(repo, path, _):
            return "/repos/\(repo)/contents/\(path)"
        case let .getTheREADME(repo, _):
            return "/repos/\(repo)/readme"

        case let .pullRequestFiles(repo, number, _):
            return "/repos/\(repo)/pulls/\(number)/files"

            // MARK: Comments

        case let .issueComments(repo, number, _):
            return "/repos/\(repo)/issues/\(number)/comments"
        case let .commitComments(repo, sha, _):
            return "/repos/\(repo)/commits/\(sha)/comments"
        case let .gistComments(gistID, _):
            return "/gists/\(gistID)/comments"

            // MARK: User

        case .oAuthUser:
            return "/user"
        case let .user(user):
            return "/users/\(user)"
        case let .organization(org):
            return "/orgs/\(org)"
        case let .organizations(user):
            return "/users/\(user)/orgs"
        case let .organizationMembers(org, _):
            return "/orgs/\(org)/members"
        case let .repositoryContributors(repo, _):
            return "/repos/\(repo)/contributors"

        case let .followedBy(user, _):
            return "/users/\(user)/following"
        case let .followersOf(user, _):
            return "/users/\(user)/followers"

        case let .isFollowing(user):
            return "/user/following/\(user)"
        case let .follow(user),
             let .unfollow(user):
            return "/user/following/\(user)"

            // MARK: Event

        case let .receivedEvents(user, _):
            return "/users/\(user)/received_events"
        case let .userEvents(user, _):
            return "/users/\(user)/events"
        case let .repositoryEvents(repo, _):
            return "/repos/\(repo)/events"
        case let .organizationEvents(org, _):
            return "/orgs/\(org)/events"

            // MARK: Issue & Pull Request

        case let .issues(repo, _, _):
            return "/repos/\(repo)/issues"
        case let .pullRequests(repo, _, _):
            return "/repos/\(repo)/pulls"

        case let .issue(owner, name, number):
            return "/repos/\(owner)/\(name)/issues/\(number)"
        case let .pullRequest(owner, name, number):
            return "/repos/\(owner)/\(name)/pulls/\(number)"

        case .authenticatedUserIssues:
            return "/issues"

            // MARK: Commit

        case let .repositoryCommits(repo, _, _):
            return "/repos/\(repo)/commits"
        case let .pullRequestCommits(repo, number, _):
            return "/repos/\(repo)/pulls/\(number)/commits"
        case let .commit(repo, sha):
            return "/repos/\(repo)/commits/\(sha)"

            // MARK: Search

        case .searchRepositories:
            return "/graphql"
        case .searchUsers:
            return "/search/users"

            // MARK: Repository

        case .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos:
            return "/graphql"

        case let .star(repo),
             let .unstar(repo):
            return "/user/starred/\(repo)"

            // MARK: Release

        case let .releases(repo, _):
            return "/repos/\(repo)/releases"

            // MARK: Gist

        case let .userGists(user, _):
            return "/users/\(user)/gists"
        case .starredGists:
            return "/gists/starred"
        }
    }

    var method: Moya.Method {
        switch self {
        case .accessToken,

             .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,

             .searchRepositories:
            return .post
        case .star,
             .follow:
            return .put
        case .unstar,
             .unfollow:
            return .delete
        default:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .authorize:
            let scope = (OAuthConfiguration.scopes as NSArray).componentsJoined(by: ",")
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "scope": scope as AnyObject]

        case let .accessToken(code):
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "code": code as AnyObject]

        case let .trending(since, language, _):
            return ["since": since.rawValue as AnyObject, "l": language as AnyObject]

        case let .oAuthUser(accessToken):
            return ["access_token": accessToken]

        case let .repositoryCommits(_, sha, page):
            return ["sha": sha, "page": page]

        case let .getContents(_, _, ref),
             let .getHTMLContents(_, _, ref),
             let .getTheREADME(_, ref):
            return ["ref": ref]

        case let .searchUsers(q, sort, page):
            return ["q": q, "sort": sort.rawValue, "page": page]

        case let .issues(_, page, state),
             let .pullRequests(_, page, state),
             let .authenticatedUserIssues(page, state):
            return ["page": page, "state": state.rawValue]

        case let .branches(_, page),

             let .followedBy(_, page),
             let .followersOf(_, page),

             let .organizationMembers(_, page),

             let .issueComments(_, _, page),
             let .commitComments(_, _, page),
             let .gistComments(_, page),

             let .receivedEvents(_, page),
             let .userEvents(_, page),
             let .organizationEvents(_, page),
             let .repositoryEvents(_, page),

             let .pullRequestCommits(_, _, page),
             let .pullRequestFiles(_, _, page),

             let .repositoryContributors(_, page),
             let .releases(_, page),

             let .userGists(_, page),
             let .starredGists(page):

            return ["page": page]

        case .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,
             .searchRepositories:
            return GraphQL.query(self)

        default:
            return nil
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .accessToken,

             .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,

             .searchRepositories:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }

    var task: Moya.Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
    }

    var sampleData: Data {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        }
    }
}

private extension String {
    var URLEscapedString: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }

    var UTF8EncodedData: Data {
        return data(using: String.Encoding.utf8)!
    }
}
