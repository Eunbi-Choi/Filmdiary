import UIKit
import FSCalendar
import JTAppleCalendar
import FirebaseAuth
import FirebaseFirestore

class MypageViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    // MARK: - UI Elements
    let profileView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let introLabel: UILabel = {
        let label = UILabel()
        label.text = "한줄 소개를 입력하세요."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let calendar = FSCalendar()
    var imagesByDate: [Date: UIImage] = [:]

    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    var movieTitle: [String] = []
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDiarySaved(_:)), name: .diarySaved, object: nil)
        
        view.backgroundColor = .white
        setupProfileView()
        
        view.addSubview(calendar)
        calendar.frame = CGRect(x: 0, y: 300, width: view.bounds.width, height: 400)
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerDateFormat = "YYYY년 M월"

        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }
    
    @objc func handleDiarySaved(_ notification: Notification) {
        if let info = notification.userInfo,
           let title = info["movieTitle"] as? String {
            movieTitle.append(title)
            calendar.reloadData()
        }
    }
    
    private func setupProfileView() {
        view.addSubview(profileView)
        profileView.addSubview(nicknameLabel)
        profileView.addSubview(introLabel)
        
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            profileView.heightAnchor.constraint(equalToConstant: 100),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 16),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 16),
            nicknameLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -16),
            
            introLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            introLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 16),
            introLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -16),
        ])
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        if let _ = imagesByDate[normalizedDate] {
            infoLabel.text = movieTitle.joined(separator: ", ")
        } else {
            infoLabel.text = "이 날은 기록이 없습니다."
        }
    }
}

extension Notification.Name {
    static let diarySaved = Notification.Name("diarySaved")
}
