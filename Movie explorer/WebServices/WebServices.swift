//
//  WebServices.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

protocol APIServiceProtocol {
    func fetchGenres(completion: @escaping (Result<[Genre], APIError>) -> Void)
    func fetchMovies(categoryID: Int?, completion: @escaping (Result<[Movie], APIError>) -> Void)
    func fetchPopularMovies(completion: @escaping (Result<[Movie], APIError>) -> Void)
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "ce8d860835749c330d21ab18c8aabc67"
    
    func fetchGenres(completion: @escaping (Result<[Genre], APIError>) -> Void) {
        let urlString = "\(baseURL)/genre/movie/list?api_key=\(apiKey)"
        request(urlString: urlString, completion: completion)
    }
    
    func fetchMovies(categoryID: Int?, completion: @escaping (Result<[Movie], APIError>) -> Void) {
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&with_genres=\(categoryID ?? 0)"
        request(urlString: urlString, completion: completion)
    }
    
    func fetchPopularMovies(completion: @escaping (Result<[Movie], APIError>) -> Void) {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)"
        request(urlString: urlString, completion: completion)
    }
    
    private func request<T: Decodable>(urlString: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjZThkODYwODM1NzQ5YzMzMGQyMWFiMThjOGFhYmM2NyIsIm5iZiI6MTc0MTA3NjE5Ni45NDU5OTk5LCJzdWIiOiI2N2M2YjZlNDY0NGVlYzcxMTRjMDdjYjIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.oof8BY76_OhjGGnNgb-6bPM2kQP6p26LTcRKAlSsS_g", forHTTPHeaderField: "Authorization") 

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response: \(response.debugDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(.requestFailed))
                return
            }
            
            // Debugging: Print JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}
