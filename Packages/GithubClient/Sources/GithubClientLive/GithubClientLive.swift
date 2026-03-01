import Foundation
import GithubClient

public extension GithubClient {
    static let live = GithubClient(
        fetchUser: { username in
            let url = URL(string: "https://api.github.com/users/\(username)")!
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw GithubClient.Error.wrongUsername
            }
            return try JSONDecoder().decode(GithubUser.self, from: data)
        },
        fetchRepos: { username in
            let url = URL(string: "https://api.github.com/users/\(username)/repos?sort=updated&per_page=10")!
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw GithubClient.Error.wrongUsername
            }
            return try JSONDecoder().decode([GithubRepo].self, from: data)
        }
    )
}
