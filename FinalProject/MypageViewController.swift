//
//  MypageViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/19/25.
//

import UIKit
import JTAppleCalendar

class MypageViewController: UIViewController {
    
    // 상단 프로필 박스만 남김
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
    
    // 캘린더 뷰 추가
    let calendarView: JTACMonthView = {
        let calendar = JTACMonthView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.minimumInteritemSpacing = 4
        calendar.backgroundColor = .black
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.showsHorizontalScrollIndicator = false
        calendar.scrollDirection = .horizontal
        calendar.allowsMultipleSelection = false
        calendar.isPagingEnabled = true
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupProfileView()
        setupCalendarView()
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
    
    private func setupCalendarView() {
        view.addSubview(calendarView)
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.register(CalendarPosterCell.self, forCellWithReuseIdentifier: "CalendarPosterCell")
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 24),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// MARK: - JTACMonthViewDataSource & Delegate
extension MypageViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // 셀 표시 직전 동작 (비워둬도 됨)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2024 01 01")!
        let endDate = formatter.date(from: "2024 12 31")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarPosterCell", for: indexPath) as! CalendarPosterCell
        cell.posterImageView.image = UIImage(named: "placeholder")
        return cell
    }
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        // 선택 시 동작 (비워둬도 됨)
    }
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        // 선택 해제 시 동작 (비워둬도 됨)
    }
}

// MARK: - CalendarPosterCell
class CalendarPosterCell: JTACDayCell {
    let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.systemGray5
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
