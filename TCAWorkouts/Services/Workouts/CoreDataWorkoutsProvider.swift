import ComposableArchitecture
import Combine

class CoreDataWorkoutsProvider: WorkoutsProvider {
    fileprivate var workouts: [Workout] = [
        Workout(name: "Morning Run", place: "Prague", duration: 45, timestemp: 3),
        Workout(name: "Swimming", place: "Prague", duration: 11, timestemp: 2),
        Workout(name: "Moninec Skiing", place: "NVpP", duration: 138, timestemp: 1)
    ]

    func getWorkouts(_ storage: Storage = .all) -> Effect<[Workout], Never> {
        return .init(value: workouts)
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
        .eraseToEffect()
    }
}
