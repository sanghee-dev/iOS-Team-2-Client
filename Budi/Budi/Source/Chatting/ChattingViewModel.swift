//
//  ChattingViewModel.swift
//  Budi
//
//  Created by leeesangheee on 2022/01/09.
//

import Combine
import Foundation
import Moya
import Firebase

final class ChattingViewModel: ViewModel {
    
    struct Action {
        let fetch = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
    }

    struct State {
        let currentUser = CurrentValueSubject<ChatUser?, Never>(nil)
        let oppositeUser = CurrentValueSubject<ChatUser?, Never>(nil)
        
        let messages = CurrentValueSubject<[ChatMessage], Never>([])
        let recentMessages = CurrentValueSubject<[ChatMessage], Never>([])
    }

    let action = Action()
    let state = State()
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<BudiTarget>()
    
    private let manager = ChatManager.shared
    
    // MARK: - Test/Users
//    let currentUser = ChatUser(id: "Yio3PM96OuRZtdhCcNJILzIQwbi1",
//                         username: "현재 유저",
//                         position: "iOS 개발자",
//                         profileImageUrl: "https://budi.s3.ap-northeast-2.amazonaws.com/post_image/default/education.jpg")
//    let oppositeUser = ChatUser(id: "3vUIvRoNGjVmBeX1Xr6DEawKf4U2",
//                         username: "상대 유저",
//                         position: "UX 디자이너",
//                         profileImageUrl: "https://budi.s3.ap-northeast-2.amazonaws.com/post_image/default/dating.jpg")

    init() {
//        createTestUserWithEmail()
        loginWithEmail()
        
        fetchCurrentUserInfo()
        fetchRecentMessages()
    }
}

// MARK: - Message
extension ChattingViewModel {
    func fetchRecentMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let query = FirebaseCollection.recentMessages(uid: currentUid).ref
            .order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, error in
            if let error = error { print("error: \(error.localizedDescription)") }
            
            guard let documents = snapshot?.documents else { return }
            let recentMessages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
            self.state.recentMessages.value = recentMessages
            print("VM recentMessages: \(recentMessages)")
        }
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let oppositeUid = state.oppositeUser.value?.id else { return }
        
        let query = FirebaseCollection.messages.ref
            .document(currentUid)
            .collection(oppositeUid)
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            if let error = error { print("error: \(error.localizedDescription)") }
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            let newMessages = changes.compactMap { try? $0.document.data(as: ChatMessage.self) }
            self.state.messages.value.append(contentsOf: newMessages)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error { print("error: \(error.localizedDescription)") }
            guard let documents = snapshot?.documents else { return }
            let messages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
            self.state.messages.value = messages
        }
    }
}

// MARK: - User
private extension ChattingViewModel {
    func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        manager.fetchUserInfo(currentUid) { [weak self] user in
            self?.state.currentUser.value = user
        }
    }
}

// MARK: - Test/User, Test/Authentication
private extension ChattingViewModel {
    func fetchOppositeUserInfo() {
        guard let oppositeUid = state.oppositeUser.value?.id else { return }
        
        manager.fetchUserInfo(oppositeUid) { [weak self] user in
            self?.state.oppositeUser.value = user
        }
    }

    func registerTestUsersInfo() {
//        manager.registerUserInfo(currentUser)
//        manager.registerUserInfo(oppositeUser)
    }
    
    func createTestUserWithEmail() {
        manager.createUserWithEmail("A@gmail.com", "123456")
        manager.createUserWithEmail("B@gmail.com", "123456")
    }

    func loginWithEmail() {
        manager.loginWithEmail("A@gmail.com", "123456")
    }
}
