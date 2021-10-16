//
//  TeamRecruitmentWritingViewController.swift
//  Budi
//
//  Created by 최동규 on 2021/10/11.
//

import UIKit

final class TeamRecruitmentWritingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        configureNavigationBar()
        configureCells()
    }

    override func viewDidLayoutSubviews() {
        let flowLayout =  UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = flowLayout
    }

    func configureCells() {
        collectionView.register(.init(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendarCell")
        collectionView.register(.init(nibName: "SelectPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "selectPhotoCell")
        collectionView.register(.init(nibName: "ProjectNameCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "projectNameCell")
        collectionView.register(.init(nibName: "LocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "locationCell")
        collectionView.register(.init(nibName: TeamRecruitmentWritingLocationCell.identifier, bundle: nil), forCellWithReuseIdentifier: TeamRecruitmentWritingLocationCell.identifier)
        collectionView.register(.init(nibName: TeamRecruitmentWritingMemberCell.identifier, bundle: nil), forCellWithReuseIdentifier: TeamRecruitmentWritingMemberCell.identifier)
        collectionView.register(.init(nibName: TeamRecruitmentWritingDescriptionCell.identifier, bundle: nil), forCellWithReuseIdentifier: TeamRecruitmentWritingDescriptionCell.identifier)
        collectionView.register(.init(nibName: TeamRecruitmentWritingPartCell.identifier, bundle: nil), forCellWithReuseIdentifier: TeamRecruitmentWritingPartCell.identifier)
    }
}

extension TeamRecruitmentWritingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {

        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectPhotoCell", for: indexPath) as? SelectPhotoCollectionViewCell else { return UICollectionViewCell() }
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor

            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "projectNameCell", for: indexPath) as? ProjectNameCollectionViewCell else { return UICollectionViewCell() }
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamRecruitmentWritingLocationCell.identifier, for: indexPath) as UICollectionViewCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamRecruitmentWritingMemberCell.identifier, for: indexPath) as UICollectionViewCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamRecruitmentWritingDescriptionCell.identifier, for: indexPath) as UICollectionViewCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        case 6:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamRecruitmentWritingLocationCell.identifier, for: indexPath) as UICollectionViewCell
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.systemGray.cgColor
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamRecruitmentWritingPartCell.identifier, for: indexPath) as UICollectionViewCell
            return cell
        }
    }
}

extension TeamRecruitmentWritingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch indexPath.item {

        case 0:
            return CGSize(width: width, height: 80)
        case 1:
            return CGSize(width: width, height: 80)
        case 2:
            return CGSize(width: width, height: 50)
        case 3:
            return CGSize(width: width, height: 50)
        case 4:
            return CGSize(width: width, height: 150)
        case 5:
            return CGSize(width: width, height: 150)
        case 6:
            return CGSize(width: width, height: 50)
        default:
            return CGSize(width: width, height: 0)
        }
    }
}

private extension TeamRecruitmentWritingViewController {
    func configureNavigationBar() {
        navigationItem.rightBarButtonItem = .init(systemItem: .done)
        title = "팀원 모집"
    }
}
