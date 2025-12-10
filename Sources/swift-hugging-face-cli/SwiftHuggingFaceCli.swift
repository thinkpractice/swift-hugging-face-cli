// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import HuggingFace

@main
struct SwiftHuggingFaceCli: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "Search string for the models")
    var search: String

    @Option(name: .shortAndLong, help: "Number of results to return")
    var numberOfResults: Int = 10

    mutating func run() async throws {
        let client = HubClient.default
        let userInfo = try await client.whoami()
        print("Logged in with: \(userInfo.name)")

        let models = try await client.listModels(search: search, limit: numberOfResults)
        for model in models.items {
            print("\(model.id)")
        }
    }
}
