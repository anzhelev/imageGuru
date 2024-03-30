//
//  DataLoader.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 29.03.2024.
//

import Foundation

final class DataLoader {
    
    // MARK: - Private Properties
    /// кейсы возможных ошибок при запросе данных с сервера
    private enum DataLoaderErrors: Error {
        case requestFail
        case wrongServerResponce
        case wrondData
        case JSONDecodeError
    }
    
    // MARK: - Public Methods
    func objectTask<T: Decodable>( for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
//                print("CONSOLE func objectTask: ", error?.localizedDescription as Any)
                completion(.failure(DataLoaderErrors.requestFail))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(DataLoaderErrors.wrongServerResponce))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(DataLoaderErrors.wrondData))
                return
            }
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch _ {
                completion(.failure(DataLoaderErrors.JSONDecodeError))
                return
            }
        }
        return task
    } 
}
