import Foundation

public struct GithubClient: Sendable {
    public enum Error: Swift.Error, LocalizedError, Sendable {
        case wrongUsername

        public var errorDescription: String? {
            switch self {
            case .wrongUsername: "Username is not valid or does not exist"
            }
        }
    }

    public var fetchUser: @Sendable (String) async throws -> GithubUser
    public var fetchRepos: @Sendable (String) async throws -> [GithubRepo]

    public init(
        fetchUser: @escaping @Sendable (String) async throws -> GithubUser,
        fetchRepos: @escaping @Sendable (String) async throws -> [GithubRepo]
    ) {
        self.fetchUser = fetchUser
        self.fetchRepos = fetchRepos
    }
}
