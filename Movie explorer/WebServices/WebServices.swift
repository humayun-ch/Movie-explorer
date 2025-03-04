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
    func fetchGenres(completion: @escaping (Result<[Genre], Error>) -> Void)
    func fetchMovies(categoryID: Int?, completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
}

class APIService: APIServiceProtocol {
    
    private let baseURL = "https://api.themoviedb.org/3/"

    private let apiKey = "ce8d860835749c330d21ab18c8aabc67"
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjZThkODYwODM1NzQ5YzMzMGQyMWFiMThjOGFhYmM2NyIsIm5iZiI6MTc0MTA3NjE5Ni45NDU5OTk5LCJzdWIiOiI2N2M2YjZlNDY0NGVlYzcxMTRjMDdjYjIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.oof8BY76_OhjGGnNgb-6bPM2kQP6p26LTcRKAlSsS_g"

    // MARK: - Fetch Genres
    func fetchGenres(completion: @escaping (Result<[Genre], Error>) -> Void) {
        let urlString = "\(baseURL)genre/movie/list?api_key=\(apiKey)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([String: [Genre]].self, from: data)
                let genres = response["genres"] ?? []
                completion(.success(genres))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch Movies by Category ID
    func fetchMovies(categoryID: Int?, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)discover/movie?api_key=\(apiKey)&access_token=\(accessToken)&with_genres=\(categoryID ?? 0)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([String: [Movie]].self, from: data)
                let movies = response["results"] ?? []
                completion(.success(movies))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch Popular Movies
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)movie/popular?api_key=\(apiKey)&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 404, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([String: [Movie]].self, from: data)
                let popularMovies = response["results"] ?? []
                completion(.success(popularMovies))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
