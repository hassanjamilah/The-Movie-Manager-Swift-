//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
        
        if let poster = movie.posterPath {
              TMDBClient.getMovieImage(imageURL: poster) { (data, error) in
                guard let data = data else {
                    print ("No data")
                    return
                }
                let image = UIImage(data: data)
                self.imageView.image = image
        }
      
            
        }
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.addToWatchList(movieId: movie.id, isWatchList: !isWatchlist) { (success:Bool, error:Error?) in
            if (success){
                if self.isWatchlist{
                    MovieModel.watchlist = MovieModel.watchlist.filter(){$0 != self.movie}
                }else {
                    MovieModel.watchlist.append(self.movie)
                }
                self.toggleBarButton(self.watchlistBarButtonItem, enabled: self.isWatchlist)
            }else {
                
            }
        }
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {

        TMDBClient.addToFavorite(movieId: movie.id, isFavorite: !isFavorite) { (success, error) in
            if success {
                if self.isFavorite{
                    MovieModel.favorites = MovieModel.favorites.filter(){$0 != self.movie}
                }else {
                    MovieModel.favorites.append(self.movie)
                }
                self.toggleBarButton(self.favoriteBarButtonItem, enabled: self.isFavorite)
            }else {
                
            }
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
}
