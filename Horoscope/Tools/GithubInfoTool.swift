//
//  Created by Artem Novichkov on 26.07.2025.
//

import Foundation
import FoundationModels

/// A tool that fetches GitHub user and repository information for a given username.
///
/// The tool uses GitHub's public API to retrieve user profile data and a list of the user's
/// most recently updated repositories (limited to 10). It caches the latest result to avoid
/// redundant API calls for the same user.
final class GithubInfoTool: Tool {
    enum ToolError: Error, LocalizedError {
        case emptyUsername
        case wrongUsername

        var errorDescription: String? {
            switch self {
            case .emptyUsername:
                "Username cannot be empty"
            case .wrongUsername:
                "Username is not valid or does not exist"
            }
        }
    }

    let name = "fetchGithubInfo"
    let description = "Fetch user and repos information from GitHub"

    private var user: GithubUser?
    private var repos: [GithubRepo]?

    @Generable
    struct Arguments {
        @Guide(description: "GitHub username to fetch information for")
        let username: String
    }

    func call(arguments: Arguments) async throws -> GeneratedContent {
        if arguments.username.isEmpty {
            throw ToolError.emptyUsername
        }

        async let user = fetchUser(username: arguments.username)
        async let repos = fetchRepos(username: arguments.username)

        return try await GeneratedContent(properties: ["user": user,
                                                       "repos": repos])
    }

    // MARK: - Private

    private func fetchUser(username: String) async throws -> GithubUser {
        if let user, user.login == username {
            return user
        }
        let url = URL(string: "https://api.github.com/users/\(username)")!
        let (userData, response) = try await URLSession.shared.data(from: url)
        if (response as? HTTPURLResponse)?.statusCode != 200 {
            throw ToolError.wrongUsername
        }
        let user = try JSONDecoder().decode(GithubUser.self, from: userData)
        self.user = user
        return user
    }

    private func fetchRepos(username: String) async throws -> [GithubRepo] {
        if let repos, repos.first?.owner.login == username {
            return repos
        }
        let reposURL = URL(string: "https://api.github.com/users/\(username)/repos?sort=updated&per_page=10")!
        let (reposData, response) = try await URLSession.shared.data(from: reposURL)
        if (response as? HTTPURLResponse)?.statusCode != 200 {
            throw ToolError.wrongUsername
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
private struct GithubUser: Decodable, ConvertibleToGeneratedContent {
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
private struct GithubRepo: Decodable, ConvertibleToGeneratedContent {
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
