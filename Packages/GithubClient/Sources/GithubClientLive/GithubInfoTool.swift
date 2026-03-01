import Foundation
import FoundationModels
import GithubClient

public final class GithubInfoTool: Tool {
    public enum Error: Swift.Error, LocalizedError {
        case emptyUsername

        public var errorDescription: String? {
            switch self {
            case .emptyUsername:
                "Username cannot be empty"
            }
        }
    }

    public let name = "fetchGithubInfo"
    public let description = "Fetch user and repos information from GitHub"

    private let githubClient: GithubClient

    public init(githubClient: GithubClient = .live) {
        self.githubClient = githubClient
    }

    @Generable
    public struct Arguments {
        @Guide(description: "GitHub username to fetch information for")
        let username: String
    }

    public func call(arguments: Arguments) async throws -> GeneratedContent {
        let username = arguments.username
        if username.isEmpty {
            throw Error.emptyUsername
        }

        async let user = githubClient.fetchUser(username)
        async let repos = githubClient.fetchRepos(username)

        return try await GeneratedContent(properties: ["user": user,
                                                       "repos": repos])
    }
}

extension GithubUser: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["name": name,
                                      "company": company,
                                      "location": location,
                                      "bio": bio])
    }
}

extension GithubRepo: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["name": name,
                                      "description": description,
                                      "language": language,
                                      "topics": topics?.joined(separator: ", ") ?? "No topics"])
    }
}
