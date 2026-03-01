public struct GithubUser: Decodable, Sendable {
    public let login: String
    public let name: String?
    public let company: String?
    public let location: String?
    public let bio: String?

    public init(login: String, name: String?, company: String?, location: String?, bio: String?) {
        self.login = login
        self.name = name
        self.company = company
        self.location = location
        self.bio = bio
    }
}

public struct GithubRepo: Decodable, Sendable {
    public struct Owner: Decodable, Sendable {
        public let login: String

        public init(login: String) {
            self.login = login
        }
    }

    public let name: String
    public let description: String?
    public let owner: Owner
    public let language: String?
    public let topics: [String]?

    public init(name: String, description: String?, owner: Owner, language: String?, topics: [String]?) {
        self.name = name
        self.description = description
        self.owner = owner
        self.language = language
        self.topics = topics
    }
}
