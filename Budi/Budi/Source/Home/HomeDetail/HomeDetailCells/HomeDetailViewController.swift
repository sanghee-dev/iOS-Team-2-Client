//
//  HomeDetailViewController.swift
//  Budi
//
//  Created by leeesangheee on 2021/11/02.
//
import UIKit
import Moya
import Combine
import CombineCocoa
import FirebaseAuth

final class HomeDetailViewController: UIViewController {

    @IBOutlet private weak var mainCollectionView: UICollectionView!
    @IBOutlet private weak var backgroundView: UIView!

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var heartButton: UIButton!
    @IBOutlet private weak var heartCountLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!

    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    init?(coder: NSCoder, viewModel: HomeDetailViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("This viewController must be init with viewModel")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.layer.addBorderTop()
        configureNavigationBar()
        configureCollectionView()
        bindViewModel()
        setPublisher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setTranslucent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.removeTranslucent()
    }
}

private extension HomeDetailViewController {
    func bindViewModel() {
        Publishers.CombineLatest3(
        viewModel.state.post,
        viewModel.state.recruitingStatuses,
        viewModel.state.teamMembers
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                if UserDefaults.standard.string(forKey: "accessToken") != "" {
                    self?.configureHeartButton()
                    self?.configureSubmitButton()
                }
                self?.mainCollectionView.reloadData()
            }).store(in: &cancellables)
    }
    
    func setPublisher() {
        submitButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, let isAlreadyApplied = self.viewModel.state.post.value?.isAlreadyApplied else { return }
                if UserDefaults.standard.string(forKey: "accessToken") == "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginSelectViewController = storyboard.instantiateViewController(identifier: "LoginSelectViewController")
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.moveLoginController(loginSelectViewController, animated: true)
                } else {
                    if isAlreadyApplied {
                        let errorAlertVC = ErrorAlertViewController(ErrorMessage.isAlreadyApplied)
                        errorAlertVC.modalPresentationStyle = .overCurrentContext
                        self.present(errorAlertVC, animated: false, completion: nil)
                    } else {
                        self.coordinator?.showRecruitingStatusBottomViewController(self, self.viewModel)
                    }
                }
            }.store(in: &cancellables)
        
        heartButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if UserDefaults.standard.string(forKey: "accessToken") == "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginSelectViewController = storyboard.instantiateViewController(identifier: "LoginSelectViewController")
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.moveLoginController(loginSelectViewController, animated: true)
                } else {
                    self.viewModel.requestLikePost(UserDefaults.standard.string(forKey: "accessToken") ?? "") { response in
                        switch response {
                        case .success:
                            guard let isLiked = self.viewModel.state.post.value?.isLiked else { return }
                            self.heartButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
                            self.heartButton.tintColor = isLiked ? UIColor.primary : UIColor.textDisabled
                        case .failure(let error): print(error.localizedDescription)
                        }
                    }
                }
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: Notification.Name("LoginSuccessed"), object: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.action.refresh.send(())
            }
            .store(in: &cancellables)

    }
}

private extension HomeDetailViewController {
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemGray
    }

    @objc
    func shareButtonTapped() {
    }
    
    func configureHeartButton() {
        guard let likeCount = viewModel.state.post.value?.likeCount, let isLiked = viewModel.state.post.value?.isLiked else { return }
        heartCountLabel.text = "\(likeCount)"
        heartButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        heartButton.tintColor = isLiked ? UIColor.primary : UIColor.textDisabled
    }
    
    func configureSubmitButton() {
        guard let isAlreadyApplied = viewModel.state.post.value?.isAlreadyApplied else { return }
        if isAlreadyApplied {
            submitButton.setTitle("지원완료", for: .normal)
            submitButton.backgroundColor = .textDisabled
        } else {
            submitButton.setTitle("지원하기", for: .normal)
            submitButton.backgroundColor = .primary
        }
    }
}

// MARK: - Delegate
extension HomeDetailViewController: RecruitingStatusBottomViewControllerDelegate {
    func getSelectedRecruitingStatus(_ selectedRecruitingStatus: RecruitingStatus) {
        viewModel.state.selectedRecruitingStatus.value = selectedRecruitingStatus

        let postId = viewModel.state.postId.value
        let param = ApplyRequest(postId: postId, recruitingPositionId: selectedRecruitingStatus.recruitingPositionId)

        viewModel.requestApply(UserDefaults.standard.string(forKey: "accessToken") ?? "", param) { result in
            switch result {
            case .success:
                self.dismiss(animated: false) {
                    self.sendRequestMessageToLeader()
                    self.coordinator?.showGreetingAlertViewController(self)
                    self.viewModel.state.post.value?.isAlreadyApplied = true
                }
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    func sendRequestMessageToLeader() {
        // MARK: - 현재유저 id값 아래의 주석처리된 코드로 변경
//        let currentUid = UserDefaults.standard.integer(forKey: "memberId")
        let currentUid = 0
        guard let leaderUid = viewModel.state.post.value?.leader.leaderId else { return }
                
        guard let projectTitle = viewModel.state.post.value?.title, let positionName = viewModel.state.selectedRecruitingStatus.value?.positions.position else { return }
        let messageText = "\(projectTitle) 프로젝트의 \(positionName) 분야에 참여 요청을 보냈습니다."
        
        ChatManager.shared.sendMessageForApply(fromId: currentUid, toId: leaderUid, text: messageText, postId: viewModel.state.postId.value, projectTitle: projectTitle, positionName: positionName)
    }
}

extension HomeDetailViewController: GreetingAlertViewControllerDelegate {
    func chattingButtonTapped() {
        coordinator?.showChattingVC(self)
    }
}

// MARK: - CollectionView
extension HomeDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func configureCollectionView() {
        HomeDetailCellType.configureCollectionView(self, mainCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        HomeDetailCellType.numberOfItemsInSection
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        HomeDetailCellType.configureCell(collectionView, indexPath, viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        HomeDetailCellType.configureCellSize(collectionView, indexPath, viewModel)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        HomeDetailCellType.minimumLineSpacingForSection
    }
}
