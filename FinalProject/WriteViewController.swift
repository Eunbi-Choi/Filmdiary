//
//  WriteViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/21/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WriteViewController: UIViewController {
    
    var movie: Movie?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 1. Movie Info Card
    private let movieInfoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.sun.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let viewingDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // 2. Emotion Tags
    private let emotionSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "🎭 감정 태그"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let emotionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // 3. Photo Attachment
    private let photoSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "📸 오늘의 사진"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("사진 추가하기", for: .normal)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .label
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let attachedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true // Initially hidden
        return imageView
    }()
    
    // 4. Diary Entry
    private let diarySectionLabel: UILabel = {
        let label = UILabel()
        label.text = "📖 텍스트 일기"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let diaryTitleField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이 영화가 내게 남긴 말"
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "이 장면에서 왜 눈물이 났을까?"
        textView.textColor = .secondaryLabel
        return textView
    }()
    
    // 5. Quote Memo
    private let quoteSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "📝 명대사 or 장면 메모"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let quoteTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15, weight: .light)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    // 6. Controls
    private let privacyControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["나만 보기", "친구 공개", "전체 공개"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveToDB), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "감상 기록하기"
        
        setupUI()
        configureWithMovie()
        //setupEmotionButtons()
        
        diaryTextView.delegate = self
    }
    
    private func configureWithMovie() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        viewingDateLabel.text = "감상일: \(dateFormatter.string(from: Date()))"
        
        if let posterPath = movie.poster_path, let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
//    private func setupEmotionButtons() {
//        let emotions = ["🧡 감동적", "🤯 충격", "🤔 생각 많음", "😂 웃김"]
//        for emotion in emotions {
//            let button = UIButton(type: .system)
//            button.setTitle(emotion, for: .normal)
//            button.titleLabel?.font = .systemFont(ofSize: 14)
//            button.backgroundColor = .systemGray5
//            button.setTitleColor(.label, for: .normal)
//            button.layer.cornerRadius = 15
//            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
//            emotionStackView.addArrangedSubview(button)
//        }
//    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [movieInfoCardView, emotionSectionLabel, emotionStackView, photoSectionLabel, addPhotoButton, attachedImageView, diarySectionLabel, diaryTitleField, diaryTextView, quoteSectionLabel, quoteTextView, privacyControl, saveButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        movieInfoCardView.addSubview(posterImageView)
        movieInfoCardView.addSubview(movieTitleLabel)
        movieInfoCardView.addSubview(viewingDateLabel)
        posterImageView.addSubview(weatherIconImageView)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        viewingDateLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 1. Movie Info Card
            movieInfoCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            movieInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            movieInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            posterImageView.topAnchor.constraint(equalTo: movieInfoCardView.topAnchor, constant: 12),
            posterImageView.leadingAnchor.constraint(equalTo: movieInfoCardView.leadingAnchor, constant: 12),
            posterImageView.bottomAnchor.constraint(equalTo: movieInfoCardView.bottomAnchor, constant: -12),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            
            weatherIconImageView.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            weatherIconImageView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -8),
            
            movieTitleLabel.topAnchor.constraint(equalTo: movieInfoCardView.topAnchor, constant: 12),
            movieTitleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            movieTitleLabel.trailingAnchor.constraint(equalTo: movieInfoCardView.trailingAnchor, constant: -12),
            
            viewingDateLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 8),
            viewingDateLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            
            // 2. Emotion Tags
            emotionSectionLabel.topAnchor.constraint(equalTo: movieInfoCardView.bottomAnchor, constant: 30),
            emotionSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            emotionStackView.topAnchor.constraint(equalTo: emotionSectionLabel.bottomAnchor, constant: 12),
            emotionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emotionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emotionStackView.heightAnchor.constraint(equalToConstant: 35),
            
            // 3. Photo Attachment
            photoSectionLabel.topAnchor.constraint(equalTo: emotionStackView.bottomAnchor, constant: 30),
            photoSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            addPhotoButton.topAnchor.constraint(equalTo: photoSectionLabel.bottomAnchor, constant: 12),
            addPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 150),
            
            attachedImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 12),
            attachedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachedImageView.widthAnchor.constraint(equalToConstant: 100),
            attachedImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // 4. Diary Entry
            diarySectionLabel.topAnchor.constraint(equalTo: attachedImageView.bottomAnchor, constant: 30),
            diarySectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            diaryTitleField.topAnchor.constraint(equalTo: diarySectionLabel.bottomAnchor, constant: 12),
            diaryTitleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            diaryTitleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            diaryTextView.topAnchor.constraint(equalTo: diaryTitleField.bottomAnchor, constant: 12),
            diaryTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            diaryTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            diaryTextView.heightAnchor.constraint(equalToConstant: 150),
            
            // 5. Quote Memo
            quoteSectionLabel.topAnchor.constraint(equalTo: diaryTextView.bottomAnchor, constant: 30),
            quoteSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            quoteTextView.topAnchor.constraint(equalTo: quoteSectionLabel.bottomAnchor, constant: 12),
            quoteTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quoteTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quoteTextView.heightAnchor.constraint(equalToConstant: 80),
            
            // 6. Controls
            privacyControl.topAnchor.constraint(equalTo: quoteTextView.bottomAnchor, constant: 30),
            privacyControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            privacyControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: privacyControl.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc func saveToDB() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        guard let uid = uid else { return }
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let nickname = document.get("nickname") as? String ?? ""
                
                db.collection("filmDiaries").document(uid)
                    .collection("myDiary").document(self.movieTitleLabel.text ?? "")
                    .setData([
                        "nickname": nickname,
                        "movieTitle": self.movieTitleLabel.text ?? "",
                        "viewingDate": self.viewingDateLabel.text ?? "",
                        "posterPath": self.movie?.poster_path ?? "",
                        "diaryTitle": self.diaryTitleField.text ?? "",
                        "diaryContent": self.diaryTextView.text ?? "",
                        "quote": self.quoteTextView.text ?? "",
                        "privacy": self.privacyControl.selectedSegmentIndex
                    ]) { error in
                        if let error = error {
                            print("저장 실패: \(error.localizedDescription)")
                        } else {
                            print("저장 성공")
                        }
                    }
                
            } else {
                print("닉네임 가져오기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
        }
    }
}

extension WriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "이 장면에서 왜 눈물이 났을까?"
            textView.textColor = .secondaryLabel
        }
    }
}
