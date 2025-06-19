//
//  ViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/18/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorTheme.background
        
        // 네비게이션 바 스타일링
        navigationController?.navigationBar.tintColor = ColorTheme.accent
        navigationController?.navigationBar.barTintColor = ColorTheme.background
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: ColorTheme.text
        ]
        
        getNowPlayingMovies()
        
        // 레이아웃 설정 (가로 스크롤)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 140, height: 220) // 셀 크기
        
        let label = UILabel()
        label.text = "현재 상영 중인 영화"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorTheme.text
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        // 컬렉션 뷰 생성
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        // 셀 등록
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        
        // 뷰에 추가
        view.addSubview(collectionView)
        
        // 오토레이아웃
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    // 데이터 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    // 셀 구성
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath)
        cell.backgroundColor = .clear
        
        // 기존 서브뷰 제거 (셀 재사용 시 깨끗하게)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 카드 뷰 생성
        let cardView = UIView()
        cardView.backgroundColor = ColorTheme.cardBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = ColorTheme.text.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cardView)
        
        // 영화 제목 라벨
        let label = UILabel()
        label.tag = 100
        label.textColor = ColorTheme.text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(label)
        
        // 포스터 이미지뷰
        let poster = UIImageView()
        poster.tag = 200
        poster.translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 12
        poster.backgroundColor = ColorTheme.main
        cardView.addSubview(poster)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
            
            poster.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            poster.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            poster.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            poster.heightAnchor.constraint(equalToConstant: 160),
            
            label.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        // 현재 영화 데이터 가져오기
        let movie = movies[indexPath.item]
        
        // 영화 제목 설정 (한국어 우선, 없으면 영어)
        let movieTitle = movie.title ?? movie.original_title ?? "제목 없음"
        label.text = movieTitle
        
        // 포스터 이미지 불러오기
        if let posterPath = movie.poster_path {
            let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
            
            if let url = imageUrl {
                // 로딩 상태 표시
                poster.image = UIImage(systemName: "film")
                poster.tintColor = ColorTheme.accent
                
                // 비동기 이미지 다운로드
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil,
                          let image = UIImage(data: data) else { 
                        DispatchQueue.main.async {
                            poster.image = UIImage(systemName: "film")
                            poster.tintColor = ColorTheme.accent
                        }
                        return 
                    }
                    
                    DispatchQueue.main.async {
                        // 셀이 여전히 같은 영화를 표시하는지 확인
                        if let currentCell = collectionView.cellForItem(at: indexPath),
                           let currentLabel = currentCell.contentView.viewWithTag(100) as? UILabel,
                           currentLabel.text == movieTitle {
                            poster.image = image
                        }
                    }
                }.resume()
            }
        } else {
            // 포스터가 없는 경우 기본 이미지
            poster.image = UIImage(systemName: "film")
            poster.tintColor = ColorTheme.accent
        }
        
        return cell
    }
}

extension HomeViewController {
    private func getTrendingMovies() {
        APICaller.shared.getTrendingMovies { results in
            switch results {
            case .success(let movies):
                print(movies)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getNowPlayingMovies() {
        APICaller.shared.getNowPlayingMovies { results in
            switch results {
            case .success(let movies):
                print(movies)
                DispatchQueue.main.async {
                    self.movies = movies
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


