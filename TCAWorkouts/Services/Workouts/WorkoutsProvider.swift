import Foundation
import ComposableArchitecture

enum Storage: String, CaseIterable {
    case all = "all"
    case onDevice = "on device"
    case remote = "in cloud"
}

protocol WorkoutsProvider {
    func getWorkouts(_ storage: Storage) -> Effect<[Workout], Never>
    func addWorkout(_ workout: Workout) -> Effect<Workout, Never>
    func removeWorkout(_ workoutId: UUID, isStoredOnThisDevice: Bool)
    func removeWorkouts(_ workoutIds: [(UUID, Bool)])
    func getFavoriteWorkouts(favoriteIds: [UUID]) -> Effect<[Workout], Never>
}

