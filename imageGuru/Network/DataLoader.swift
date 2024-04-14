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
        case requestFail(Error)
        case wrongServerResponce(String)
        case wrondData
        case JSONDecodeError(Error)
    }
    
    // MARK: - Public Methods
    /// generic функция сетевого запроса
    func objectTask<T: Decodable>( for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let error = error {
                completion(.failure(DataLoaderErrors.requestFail(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(DataLoaderErrors.wrongServerResponce("Код ответа сервера: \(response.statusCode)")))
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
            } catch {
                completion(.failure(DataLoaderErrors.JSONDecodeError(error)))
                return
            }
        }
        
        task.resume()
        return task
    } 
}
