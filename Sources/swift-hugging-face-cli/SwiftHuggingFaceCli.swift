// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import HuggingFace

@main
struct SwiftHuggingFaceCli: AsyncParsableCommand {

    @Option(name: .shortAndLong, help: "Search string for the models")
    var search: String

    @Option(name: .shortAndLong, help: "Number of results to return")
    var numberOfResults: Int = 10

    @Option(name: .shortAndLong, help: "Destination path for model")
    var destinationPath: String = "./models"

    func downloadFile(client: HubClient, repo: Repo.ID, file: Git.TreeEntry, to destination: URL)
        async throws
    {
        // Download with progress tracking
        let progress = Progress(totalUnitCount: 0)
        /*Task {
            for await _ in progress.values(forKeyPath: \.fractionCompleted) {
                print("Download progress: \(progress.fractionCompleted * 100)%")
            }
        }*/

        let fileURL = try await client.downloadFile(
            at: file.path,
            from: repo,
            to: destination,
            progress: progress
        )
        print("Downloaded file url: \(fileURL.absoluteString)")
    }

    mutating func run() async throws {
        let client = HubClient.default
        let userInfo = try await client.whoami()
        print("Logged in with: \(userInfo.name)")

        let models = try await client.listModels(search: search, limit: numberOfResults)
        for model in models.items {
            print("\(model.id)")
        }

        guard let firstModel = models.items.first else {
            print("No models found")
            return
        }
        // Get model information
        let model = try await client.getModel(firstModel.id)
        print("Model: \(model.id)")
        print("Downloads: \(model.downloads ?? 0)")
        print("Likes: \(model.likes ?? 0)")

        let modelDirectory = URL(filePath: destinationPath).appending(path: "\(model.id)")

        // Get model tags
        do {
            let tags = try await client.getModelTags()
            print("Tags \(tags.map { "\($0.key):\($0.value)" }.joined(separator: ","))")
        } catch {
            print("Error retrieving tags:\n \(error)")
        }

        let files = try await client.listFiles(
            in: model.id, kind: .model, revision: "main", recursive: true)
        for file in files {
            print(file.path)
            if file.type == .file {
                print("Downloading: \(file.path)")
                let filePath = modelDirectory.appending(path: file.path)
                try await downloadFile(
                    client: client, repo: firstModel.id, file: file, to: filePath)
                print("Ready")
            }
        }
    }
}
