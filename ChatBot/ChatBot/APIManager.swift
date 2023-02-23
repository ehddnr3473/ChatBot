//
//  APIManager.swift
//  ChatBot
//
//  Created by 김동욱 on 2023/02/23.
//

import Foundation
import OpenAISwift

final class APIManager {
    static let shared = APIManager()
    
    @frozen enum Constants {
        static let key = Bundle.main.infoDictionary?["API_KEY"] as! String
    }
    
    private var client: OpenAISwift?
    
    private init() {}
    
    func setUp() {
        client = OpenAISwift(authToken: Constants.key)
    }
    
    func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        client?.sendCompletion(with: input, model: .gpt3(.davinci), maxTokens: 100, completionHandler: { result in
            switch result {
            case .success(let model):
                print(String(describing: model.choices))
                let output = model.choices.first?.text ?? ""
                completion(.success(output))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
