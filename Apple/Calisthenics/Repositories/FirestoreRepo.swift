import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftData

class FirestoreRepo: ObservableObject {
    private let db = Firestore.firestore()

    // Function to initiate migration with access to ModelContext
    func migrateSwiftDataToFirestore(modelContext: ModelContext) {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        let userId = user.uid
        let userDocRef = db.collection("users").document(userId)

        userDocRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error checking for Firestore document: \(error)")
                return
            }

            if let document = document, document.exists {
                print("Firestore document already exists for user")
            } else {
                print("Firestore document does not exist, migrating data...")
                self?.createFirestoreDocument(for: userId, modelContext: modelContext)
            }
        }
    }

    // Function to create Firestore document and migrate data
    private func createFirestoreDocument(for userId: String, modelContext: ModelContext) {
        let userDocRef = db.collection("users").document(userId)

        do {
            // Create FetchDescriptors to fetch all instances
            let exerciseFetchDescriptor = FetchDescriptor<Exercise>()
            let exercises = try modelContext.fetch(exerciseFetchDescriptor)

            let stashedExerciseFetchDescriptor = FetchDescriptor<StashedExercise>()
            let stashedExercises = try modelContext.fetch(stashedExerciseFetchDescriptor)

            // Migrate Exercises
            for exercise in exercises {
                guard let exerciseID = exercise.id?.uuidString else {
                    print("Exercise ID is nil")
                    continue
                }

                let exerciseData: [String: Any] = [
                    "currentReps": exercise.currentReps ?? 0,
                    "difficulty": exercise.difficulty ?? "",
                    "isActive": exercise.isActive ?? false,
                    "notes": exercise.notes ?? "",
                    "title": exercise.title ?? "",
                    "units": exercise.units ?? "",
                    "increment": exercise.increment ?? 0,
                    "incrementIncrement": exercise.incrementIncrement ?? 0,
                    "leftRight": exercise.leftRight ?? false,
                    "leftSide": exercise.leftSide ?? false
                ]

                let exerciseDocRef = userDocRef.collection("exercises").document(exerciseID)
                exerciseDocRef.setData(exerciseData) { error in
                    if let error = error {
                        print("Error writing Exercise data: \(error)")
                    } else {
                        print("Exercise data migrated for ID: \(exerciseID)")
                    }
                }

                // Migrate Logs for each Exercise
                if let logs = exercise.logs {
                    for log in logs {
                        guard let logID = log.id?.uuidString else {
                            print("Log ID is nil")
                            continue
                        }

                        let logData: [String: Any] = [
                            "duration": log.duration ?? 0,
                            "reps": log.reps ?? 0,
                            "timestamp": log.timestamp ?? Date(),
                            "units": log.units ?? "",
                            "difficulty": log.difficulty ?? "",
                            "side": log.side ?? ""
                        ]

                        let logDocRef = exerciseDocRef.collection("logs").document(logID)
                        logDocRef.setData(logData) { error in
                            if let error = error {
                                print("Error writing Log data: \(error)")
                            } else {
                                print("Log data migrated for ID: \(logID)")
                            }
                        }
                    }
                }
            }

            // Migrate StashedExercises
            for stashedExercise in stashedExercises {
                guard let stashedExerciseID = stashedExercise.id?.uuidString else {
                    print("StashedExercise ID is nil")
                    continue
                }

                let stashedExerciseData: [String: Any] = [
                    "currentReps": stashedExercise.currentReps ?? 0,
                    "difficulty": stashedExercise.difficulty ?? "",
                    "isActive": stashedExercise.isActive ?? false,
                    "notes": stashedExercise.notes ?? "",
                    "title": stashedExercise.title ?? "",
                    "units": stashedExercise.units ?? "",
                    "increment": stashedExercise.increment ?? 0,
                    "incrementIncrement": stashedExercise.incrementIncrement ?? 0,
                    "leftRight": stashedExercise.leftRight ?? false,
                    "leftSide": stashedExercise.leftSide ?? false
                ]

                let stashedExerciseDocRef = userDocRef.collection("stashedExercises").document(stashedExerciseID)
                stashedExerciseDocRef.setData(stashedExerciseData) { error in
                    if let error = error {
                        print("Error writing StashedExercise data: \(error)")
                    } else {
                        print("StashedExercise data migrated for ID: \(stashedExerciseID)")
                    }
                }
            }

            print("Migration completed successfully")
        } catch {
            print("Failed to fetch data from SwiftData: \(error)")
        }
    }
}
