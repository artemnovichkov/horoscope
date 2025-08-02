//
//  Created by Artem Novichkov on 02.08.2025.
//

import Foundation
import FoundationModels

final class GithubService {
    enum Error: Swift.Error, LocalizedError {
        case wrongUsername

        var errorDescription: String? {
            switch self {
            case .wrongUsername:
                "Username is not valid or does not exist"
            }
        }
    }

    private var user: GithubUser?
    private var repos: [GithubRepo]?

    func fetchUser(username: String) async throws -> GithubUser {
        if let user, user.login == username {
            return user
        }
        let url = URL(string: "https://api.github.com/users/\(username)")!
        let (userData, response) = try await URLSession.shared.data(from: url)
        if (response as? HTTPURLResponse)?.statusCode != 200 {
            throw Error.wrongUsername
        }
        let user = try JSONDecoder().decode(GithubUser.self, from: userData)
        self.user = user
        return user
    }

    func fetchRepos(username: String) async throws -> [GithubRepo] {
        if let repos, repos.first?.owner.login == username {
            return repos
        }
        let reposURL = URL(string: "https://api.github.com/users/\(username)/repos?sort=updated&per_page=10")!
        let (reposData, response) = try await URLSession.shared.data(from: reposURL)
        if (response as? HTTPURLResponse)?.statusCode != 200 {
            throw Error.wrongUsername
        }
        let repos = try JSONDecoder().decode([GithubRepo].self, from: reposData)
        self.repos = repos
        return repos
    }
}

/// Represents a GitHub user with selected profile fields.
///
/// Conforms to `ConvertibleToGeneratedContent` for use in Foundation Model pipelines.
/// Includes fields such as `login`, `name`, `company`, `location`, and `bio`.
struct GithubUser: Decodable, ConvertibleToGeneratedContent {
    let login: String
    let name: String?
    let company: String?
    let location: String?
    let bio: String?

    var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["name": name,
                                      "company": company,
                                      "location": location,
                                      "bio": bio])
    }
}

/// Represents a GitHub repository with basic metadata.
///
/// Includes the repository name, description, primary language, topics, and owner.
/// Conforms to `ConvertibleToGeneratedContent` for use in Foundation Model pipelines.
struct GithubRepo: Decodable, ConvertibleToGeneratedContent {
    struct Owner: Decodable {
        let login: String
    }

    let name: String
    let description: String?
    let owner: Owner
    let language: String?
    let topics: [String]?

    var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["name": name,
                                      "description": description,
                                      "language": language,
                                      "topics": topics?.joined(separator: ", ") ?? "No topics"])
    }
}
