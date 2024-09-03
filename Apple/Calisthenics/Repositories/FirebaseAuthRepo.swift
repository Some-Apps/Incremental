import FirebaseAuth

class FirebaseAuthRepo: ObservableObject {
    func signInAnonymously(completion: @escaping (Bool) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Failed to sign in anonymously: \(error)")
                completion(false)
            } else {
                print("Signed in anonymously")
                completion(true)
            }
        }
    }
}
