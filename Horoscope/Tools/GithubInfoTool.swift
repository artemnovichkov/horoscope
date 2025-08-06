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
@MainActor
final class GithubInfoTool: Tool {
    enum Error: Swift.Error, LocalizedError {
        case emptyUsername

        var errorDescription: String? {
            switch self {
            case .emptyUsername:
                "Username cannot be empty"
            }
        }
    }

    let name = "fetchGithubInfo"
    let description = "Fetch user and repos information from GitHub"

    private let githubService = GithubService()

    @Generable
    struct Arguments {
        @Guide(description: "GitHub username to fetch information for")
        let username: String
    }

    func call(arguments: Arguments) async throws -> GeneratedContent {
        if arguments.username.isEmpty {
            throw Error.emptyUsername
        }

        async let user = githubService.fetchUser(username: arguments.username)
        async let repos = githubService.fetchRepos(username: arguments.username)

        return try await GeneratedContent(properties: ["user": user,
                                                       "repos": repos])
    }
}
