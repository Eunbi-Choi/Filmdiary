//
//  MypageViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/19/25.
//

import UIKit

class MypageViewController: UIViewController {
    
    // 상단 프로필 박스
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
    // 캘린더 상단 (연/월, 이전/다음 버튼)
    let calendarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let prevMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("<", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let nextMonthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(">", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // 요일 헤더
    let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    // 캘린더 컬렉션뷰
    let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    // 달력 데이터
    var currentYear: Int = Calendar.current.component(.year, from: Date())
    var currentMonth: Int = Calendar.current.component(.month, from: Date())
    var days: [Int?] = [] // nil은 빈칸, Int는 날짜
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupProfileView()
        setupCalendarHeader()
        setupWeekdayHeader()
        setupCalendarCollectionView()
        updateCalendar()
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
    private func setupCalendarHeader() {
        view.addSubview(calendarHeaderView)
        calendarHeaderView.addSubview(prevMonthButton)
        calendarHeaderView.addSubview(monthLabel)
        calendarHeaderView.addSubview(nextMonthButton)
        prevMonthButton.addTarget(self, action: #selector(didTapPrevMonth), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(didTapNextMonth), for: .touchUpInside)
        NSLayoutConstraint.activate([
            calendarHeaderView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 24),
            calendarHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            calendarHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            calendarHeaderView.heightAnchor.constraint(equalToConstant: 40),
            prevMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            prevMonthButton.leadingAnchor.constraint(equalTo: calendarHeaderView.leadingAnchor),
            prevMonthButton.widthAnchor.constraint(equalToConstant: 40),
            monthLabel.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: calendarHeaderView.centerXAnchor),
            nextMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            nextMonthButton.trailingAnchor.constraint(equalTo: calendarHeaderView.trailingAnchor),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    private func setupWeekdayHeader() {
        view.addSubview(weekdayStackView)
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = day == "일" ? .systemRed : (day == "토" ? .systemBlue : .black)
            weekdayStackView.addArrangedSubview(label)
        }
        NSLayoutConstraint.activate([
            weekdayStackView.topAnchor.constraint(equalTo: calendarHeaderView.bottomAnchor, constant: 8),
            weekdayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekdayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    private func setupCalendarCollectionView() {
        view.addSubview(calendarCollectionView)
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            calendarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // 달력 데이터 갱신
    private func updateCalendar() {
        monthLabel.text = "\(currentYear)년 \(currentMonth)월"
        days = makeDays(year: currentYear, month: currentMonth)
        calendarCollectionView.reloadData()
    }
    // 달력 배열 생성 (빈칸 포함)
    private func makeDays(year: Int, month: Int) -> [Int?] {
        var result: [Int?] = []
        let calendar = Calendar.current
        var components = DateComponents(year: year, month: month, day: 1)
        guard let firstDay = calendar.date(from: components) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay) // 1:일~7:토
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        let numDays = range.count
        // 앞 빈칸
        for _ in 1..<weekday { result.append(nil) }
        // 날짜
        for day in 1...numDays { result.append(day) }
        return result
    }
    // 월 이동
    @objc private func didTapPrevMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        updateCalendar()
    }
    @objc private func didTapNextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        updateCalendar()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MypageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        if let day = days[indexPath.item] {
            cell.configure(day: day)
        } else {
            cell.configureEmpty()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 0
        let columns: CGFloat = 7
        let totalSpacing = spacing * (columns - 1)
        let width = (collectionView.frame.width - totalSpacing) / columns
        let height = width / 2 * 3 + 20
        return CGSize(width: width, height: height)
    }
}

// MARK: - CalendarCell
class CalendarCell: UICollectionViewCell {
    let dayLabel = UILabel()
    let photoImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = UIFont.systemFont(ofSize: 13)
        dayLabel.textAlignment = .center
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        contentView.addSubview(photoImageView)
        contentView.addSubview(dayLabel)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 3.0/2.0),
            dayLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 2),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            dayLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(day: Int) {
        dayLabel.text = "\(day)일"
        dayLabel.isHidden = false
        photoImageView.image = nil // 나중에 날짜별 사진 연결
        contentView.alpha = 1.0
    }
    func configureEmpty() {
        dayLabel.text = ""
        dayLabel.isHidden = true
        photoImageView.image = nil
        contentView.alpha = 0.0 // 빈칸은 안보이게
    }
}
