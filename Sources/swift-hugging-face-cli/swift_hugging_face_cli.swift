// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import HuggingFace

@main
struct swift_hugging_face_cli: AsyncParsableCommand {

    mutating func run() async throws {
        let client = HubClient.default
        let userInfo = try await client.whoami()
        print("\(userInfo)")
    }
}
