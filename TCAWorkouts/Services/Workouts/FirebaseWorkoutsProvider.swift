import ComposableArchitecture
import Combine

class FirebaseWorkoutsProvider: WorkoutsProvider {
    fileprivate var workouts: [Workout] = [
        Workout(name: "Evening Run", place: "Brno", duration: 27, timestemp: 0),
        Workout(name: "Walking", place: "Barcelona", duration: 54, timestemp: 4),
    ]

    func getWorkouts(_ storage: Storage = .all) -> Effect<[Workout], Never> {
        for i in 0..<workouts.count {
            workouts[i].isStoredOnThisDevice = false
        }
        
        return .init(value: workouts)
            //.delay(for: 2, scheduler: DispatchQueue.main)
            .eraseToEffect()
    }
    
    func addWorkout(_ workout: Workout) -> Effect<Workout, Never> {
        workouts.append(workout)
        
        return .init(value: workout)
    }
    
    func removeWorkout(_ workoutId: UUID, isStoredOnThisDevice: Bool) {
        workouts.removeAll { $0.id == workoutId }
    }

    func removeWorkouts(_ workoutIds: [(UUID, Bool)]) {
        for workoutId in workoutIds {
            workouts.removeAll { $0.id == workoutId.0 }
        }
    }

    func getFavoriteWorkouts(favoriteIds: [UUID]) -> Effect<[Workout], Never> {
        .init(value: workouts.compactMap { workout in
            for id in favoriteIds {
                if id == workout.id {
                    return workout
                }
            }
            
            return nil
        })
        //.delay(for: 2, scheduler: DispatchQueue.main)
        .eraseToEffect()
    }
}
