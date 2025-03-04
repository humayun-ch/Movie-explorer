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
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}
