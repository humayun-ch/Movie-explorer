//
//  MovieViewModel.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

import Foundation

class MovieViewModel {
    private let apiService: APIServiceProtocol
    
    var genres: [Genre] = []
    var movies: [Movie] = []
    var popularMovies: [Movie] = []
    
    var onGenresFetched: (() -> Void)?
    var onMoviesFetched: (() -> Void)?
    var onPopularMoviesFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func loadGenres() {
        apiService.fetchGenres { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let genres):
                    self?.genres = genres
                    self?.onGenresFetched?()
                case .failure(let error):
                    self?.onError?("Error fetching genres: \(error)")
                }
            }
        }
    }
    
    func loadMovies(categoryID: Int?) {
        apiService.fetchMovies(categoryID: categoryID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.onMoviesFetched?()
                case .failure(let error):
                    self?.onError?("Error fetching movies: \(error)")
                }
            }
        }
    }
    
    func loadPopularMovies() {
        apiService.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.popularMovies = movies
                    self?.onPopularMoviesFetched?()
                case .failure(let error):
                    self?.onError?("Error fetching popular movies: \(error)")
                }
            }
        }
    }
}
