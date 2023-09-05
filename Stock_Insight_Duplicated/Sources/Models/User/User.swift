import Foundation
import UIKit

// MARK: - User

struct User: Codable{
    var user_id: String
    var pw: String
    var name: String
}

class UserManager {
    static let shared = UserManager()
    
    private var user: User?

    
    func setUser(_ newUser: User) {
        user = newUser
    }
    
    func getUser() -> User? {
        return user
    }

    
    func setUserName(name : String){
        user?.name = name
    }
}

