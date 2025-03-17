//
//  GptResponseModel.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 02/03/2025.
//

import Foundation

// MARK: - Request & Response Models

// The request body for the OpenAI completion endpoint.
struct CompletionRequest: Encodable {
    let model: String
    let prompt: String
    let max_tokens: Int
    let temperature: Double
}

// The structure for each suggestion in the response.
struct Choice: Decodable {
    let text: String
    let index: Int
    let finish_reason: String?
}

// The response model for the OpenAI API.
struct CompletionResponse: Decodable {
    let id: String
    let choices: [Choice]
    // You can also include usage if needed:
    // let usage: Usage
}

// MARK: - Request & Response Models for Chat Completions

// Make ChatMessage Codable (which includes Decodable)
struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let max_tokens: Int
    let temperature: Double
}

struct ChatChoice: Decodable {
    let message: ChatMessage
    let index: Int
    let finish_reason: String?
}

struct ChatCompletionResponse: Decodable {
    let id: String
    let choices: [ChatChoice]
}
