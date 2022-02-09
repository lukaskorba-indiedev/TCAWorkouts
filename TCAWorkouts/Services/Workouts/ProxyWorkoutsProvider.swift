import ComposableArchitecture
import Combine

class ProxyWorkoutsProvider: WorkoutsProvider {
    let onDeviceWorkoutsProvider: WorkoutsProvider
    let remoteWorkoutsProvider: WorkoutsProvider

    init(onDeviceWorkoutsProvider: WorkoutsProvider,
         remoteWorkoutsProvider: WorkoutsProvider) {
        self.onDeviceWorkoutsProvider = onDeviceWorkoutsProvider
        self.remoteWorkoutsProvider = remoteWorkoutsProvider
    }
    
    func getWorkouts(_ storage: Storage = .all) -> Effect<[Workout], Never> {
        switch storage {
        case .all:
            return .init(
                Publishers.Merge(
                    onDeviceWorkoutsProvider.getWorkouts(.all),
                    remoteWorkoutsProvider.getWorkouts(.all)
                )
            )
            
        case .onDevice:
            return onDeviceWorkoutsProvider.getWorkouts(.all)
            
        case .remote:
            return remoteWorkoutsProvider.getWorkouts(.all)
        }
    }
    
    func addWorkout(_ workout: Workout) -> Effect<Workout, Never> {
        if workout.isStoredOnThisDevice {
            return onDeviceWorkoutsProvider.addWorkout(workout)
        } else {
            return remoteWorkoutsProvider.addWorkout(workout)
        }
    }
    
    func removeWorkout(_ workoutId: UUID, isStoredOnThisDevice: Bool) {
        if isStoredOnThisDevice {
            onDeviceWorkoutsProvider.removeWorkout(workoutId, isStoredOnThisDevice: isStoredOnThisDevice)
        } else {
            remoteWorkoutsProvider.removeWorkout(workoutId, isStoredOnThisDevice: isStoredOnThisDevice)
        }
    }

    func removeWorkouts(_ workoutIds: [(UUID, Bool)]) {
        for workoutId in workoutIds {
            if workoutId.1 {
                onDeviceWorkoutsProvider.removeWorkout(workoutId.0, isStoredOnThisDevice: workoutId.1)
            } else {
                remoteWorkoutsProvider.removeWorkout(workoutId.0, isStoredOnThisDevice: workoutId.1)
            }
        }
    }

    func getFavoriteWorkouts(favoriteIds: [UUID]) -> Effect<[Workout], Never> {
        return .init(
            Publishers.Merge(
                onDeviceWorkoutsProvider.getFavoriteWorkouts(favoriteIds: favoriteIds),
                remoteWorkoutsProvider.getFavoriteWorkouts(favoriteIds: favoriteIds)
            )
        )
    }
}
