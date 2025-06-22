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
        scrollView.backgroundColor = ColorTheme.background
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorTheme.background
        return view
    }()

    private let movieInfoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorTheme.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorTheme.text.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.clipsToBounds = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = ColorTheme.main.withAlphaComponent(0.15)
        return imageView
    }()
    
    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.sun.fill")
        imageView.tintColor = ColorTheme.accent
        return imageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let viewingDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = ColorTheme.secondaryText
        return label
    }()
    
    private let emotionSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "감상 키워드"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let exampleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private let emotionInputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "감정 키워드 입력"
        tf.font = .systemFont(ofSize: 15)
        tf.borderStyle = .roundedRect
        tf.backgroundColor = ColorTheme.cardBackground
        tf.textColor = ColorTheme.text
        tf.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.2).cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 8
        return tf
    }()
    
    private let addEmotionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("추가", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.backgroundColor = ColorTheme.main
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let emotionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()
    
    private var emotionTags: [String] = []
    
    private let attachedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = ColorTheme.cardBackground
        imageView.isHidden = true
        return imageView
    }()
    
    private let diarySectionLabel: UILabel = {
        let label = UILabel()
        label.text = "📖 텍스트 일기"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let diaryTitleField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목"
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = ColorTheme.cardBackground
        textField.textColor = ColorTheme.text
        textField.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.2).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.2).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.backgroundColor = ColorTheme.cardBackground
        textView.textColor = ColorTheme.text
        textView.textColor = .secondaryLabel
        return textView
    }()
    
    private let quoteSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "📝 명대사 or 장면 메모"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let quoteTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15, weight: .light)
        textView.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.2).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.backgroundColor = ColorTheme.cardBackground
        textView.textColor = ColorTheme.text
        return textView
    }()
    
    private let privacyControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["나만 보기", "전체 공개"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = ColorTheme.cardBackground
        control.selectedSegmentTintColor = ColorTheme.main
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorTheme.secondaryText,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorTheme.text,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)
        control.layer.cornerRadius = 16
        control.clipsToBounds = true
        return control
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = ColorTheme.main
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveToDB), for: .touchUpInside)
        return button
    }()
    
    // 예시 키워드
    private let exampleKeywords = ["잔잔한", "힐링", "슬픈", "행복한", "OST 굿"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorTheme.background
        title = "감상 기록하기"
        
        setupUI()
        configureWithMovie()
        
        diaryTextView.delegate = self
        
        addEmotionButton.addTarget(self, action: #selector(addEmotionTag), for: .touchUpInside)
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
    
    private func setupEmotionButtons() {
        let emotions = ["🧡 감동적", "🤯 충격", "🤔 생각 많음", "😂 웃김"]
        for emotion in emotions {
            let button = UIButton(type: .system)
            button.setTitle(emotion, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 15
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            emotionStackView.addArrangedSubview(button)
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [movieInfoCardView, emotionSectionLabel, exampleStackView, emotionInputField, addEmotionButton, emotionStackView, attachedImageView, diarySectionLabel, diaryTitleField, diaryTextView, quoteSectionLabel, quoteTextView, privacyControl, saveButton].forEach {
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
            
            exampleStackView.topAnchor.constraint(equalTo: emotionSectionLabel.bottomAnchor, constant: 8),
            exampleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exampleStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            emotionInputField.topAnchor.constraint(equalTo: exampleStackView.bottomAnchor, constant: 8),
            emotionInputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emotionInputField.widthAnchor.constraint(equalToConstant: 140),
            emotionInputField.heightAnchor.constraint(equalToConstant: 36),
            
            addEmotionButton.centerYAnchor.constraint(equalTo: emotionInputField.centerYAnchor),
            addEmotionButton.leadingAnchor.constraint(equalTo: emotionInputField.trailingAnchor, constant: 8),
            addEmotionButton.widthAnchor.constraint(equalToConstant: 60),
            addEmotionButton.heightAnchor.constraint(equalToConstant: 36),
            
            emotionStackView.topAnchor.constraint(equalTo: emotionInputField.bottomAnchor, constant: 10),
            emotionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emotionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            attachedImageView.topAnchor.constraint(equalTo: emotionStackView.bottomAnchor, constant: 12),
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
        
        setupExampleKeywordButtons()
    }
    
    private func setupExampleKeywordButtons() {
        exampleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for keyword in exampleKeywords {
            let btn = UIButton(type: .system)
            btn.setTitle(keyword, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14)
            btn.backgroundColor = ColorTheme.cardBackground
            btn.setTitleColor(ColorTheme.text, for: .normal)
            btn.layer.cornerRadius = 15
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            btn.layer.borderColor = UIColor(red: 255/255, green: 188/255, blue: 188/255, alpha: 1.0).cgColor
            btn.addTarget(self, action: #selector(exampleKeywordTapped(_:)), for: .touchUpInside)
            exampleStackView.addArrangedSubview(btn)
        }
    }
    
    @objc private func exampleKeywordTapped(_ sender: UIButton) {
        guard let keyword = sender.title(for: .normal) else { return }
        guard !emotionTags.contains(keyword) else { return }
        emotionTags.append(keyword)
        updateEmotionTagsUI()
    }
    
    @objc func saveToDB() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        guard let uid = uid else { return }
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let nickname = document.get("nickname") as? String ?? ""
                
                let movieTitle = self.movieTitleLabel.text ?? ""
                    let viewingDate = self.viewingDateLabel.text ?? ""
                    let posterPath = self.movie?.poster_path ?? ""
                    let diaryTitle = self.diaryTitleField.text ?? ""
                    let diaryContent = self.diaryTextView.text ?? ""
                    let quote = self.quoteTextView.text ?? ""
                    let privacy = self.privacyControl.selectedSegmentIndex
                    let tags = self.emotionTags

                    let diaryData: [String: Any] = [
                        "nickname": nickname,
                        "movieTitle": movieTitle,
                        "viewingDate": viewingDate,
                        "posterPath": posterPath,
                        "diaryTitle": diaryTitle,
                        "diaryContent": diaryContent,
                        "quote": quote,
                        "privacy": privacy,
                        "tag": tags
                    ]
                
                db.collection("filmDiaries").document(nickname)
                    .collection("myDiary").document(self.movieTitleLabel.text ?? "")
                    .setData(diaryData) { error in
                        if let error = error {
                            print("저장 실패: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                            NotificationCenter.default.post(name: NSNotification.Name("FeedUpdated"), object: nil)
                        }
                    }
                
            } else {
                print("닉네임 가져오기 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
        }
        
    }
    
    @objc private func addEmotionTag() {
        guard let text = emotionInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        guard !emotionTags.contains(text) else { emotionInputField.text = ""; return }
        emotionTags.append(text)
        emotionInputField.text = ""
        updateEmotionTagsUI()
    }
    
    private func updateEmotionTagsUI() {
        // 기존 태그 뷰 모두 제거
        emotionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 한 줄에 최대 3개씩 배치
        var rowStack: UIStackView = makeRowStack()
        var count = 0
        for tag in emotionTags {
            let tagView = makeTagView(for: tag)
            rowStack.addArrangedSubview(tagView)
            count += 1
            if count % 3 == 0 {
                emotionStackView.addArrangedSubview(rowStack)
                rowStack = makeRowStack()
            }
        }
        if rowStack.arrangedSubviews.count > 0 {
            emotionStackView.addArrangedSubview(rowStack)
        }
    }
    
    private func makeRowStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }
    
    private func makeTagView(for tag: String) -> UIView {
        let container = UIView()
        container.backgroundColor = ColorTheme.cardBackground
        container.layer.cornerRadius = 15
        container.clipsToBounds = true

        let label = UILabel()
        label.text = tag
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorTheme.text
        label.translatesAutoresizingMaskIntoConstraints = false

        let removeButton = UIButton(type: .system)
        removeButton.setTitle("x", for: .normal)
        removeButton.setTitleColor(ColorTheme.secondaryText, for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        removeButton.addTarget(self, action: #selector(removeEmotionTag(_:)), for: .touchUpInside)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.tag = emotionTags.firstIndex(of: tag) ?? 0

        container.addSubview(label)
        container.addSubview(removeButton)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            removeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
            removeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            removeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 30)
        ])

        return container
    }
    
    @objc private func removeEmotionTag(_ sender: UIButton) {
        let index = sender.tag
        guard index < emotionTags.count else { return }
        emotionTags.remove(at: index)
        updateEmotionTagsUI()
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
