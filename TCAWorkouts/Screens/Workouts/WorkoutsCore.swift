import ComposableArchitecture
import SwiftUI

struct WorkoutsState: Equatable {
    // app state
    var workouts = IdentifiedArrayOf<Workout>()
    var favorites = Set<UUID>()

    // domain state
    var workoutToAdd: Workout? = nil
    var storageFilter = Storage.all
    
    // helper functions
    mutating func sortWorkouts() {
        workouts.sort { lhs, rhs in
            lhs.timestemp > rhs.timestemp
        }
    }
    
    var filteredWorkouts: IdentifiedArrayOf<Workout> {
        switch storageFilter {
        case .all: return workouts
        case .onDevice: return workouts.filter { $0.isStoredOnThisDevice }
        case .remote: return workouts.filter { !$0.isStoredOnThisDevice }
        }
    }
}

enum WorkoutsAction: Equatable {
    // domain actions
    case onAppear
    case pullToRefreshTriggered
    case addWorkoutTapped
    case dismissAndSaveWorkout

    // new workout
    case addWorkout(AddWorkoutAction)
    case workout(id: UUID, action: WorkoutAction)
    case newWorkoutAdded(Workout)

    // removal
    case onDeleteTriggered(IndexSet)
    
    // filter
    case filterChanged(Storage)
}

struct WorkoutsEnvironment {
    let workoutsProvider: WorkoutsProvider
    let favoritesProvider: FavoritesProvider
}

let workoutsReducer = Reducer<WorkoutsState, WorkoutsAction, WorkoutsEnvironment>.combine(
    addWorkoutReducer.pullback(
        state: \.workoutToAdd,
        action: /WorkoutsAction.addWorkout,
        environment: { _ in}),
    
    workoutReducer.forEach(
        state: \.workouts,
        action: /WorkoutsAction.workout(id:action:),
        environment: { environment in
            WorkoutEnvironment(favoritesProvider: environment.favoritesProvider)
        }
    ),
    
        .init { state, action, environment in
            switch action {
                
            case .onAppear:
                return .none
                
            case .pullToRefreshTriggered:
                return .init(value: .onAppear)
                
            case .addWorkoutTapped:
                state.workoutToAdd = Workout(
                    name: "workout",
                    place: "place",
                    duration: 87
                )
                
                return .none
                
            case .dismissAndSaveWorkout:
                state.workoutToAdd?.timestemp = Date().timeIntervalSince1970
                
                if let workoutToAdd = state.workoutToAdd {
                    state.workouts.append(workoutToAdd)
                    state.sortWorkouts()
                }

                if let workout = state.workoutToAdd {
                    return environment.workoutsProvider.addWorkout(workout)
                        .map(WorkoutsAction.newWorkoutAdded)
                } else {
                    return .none
                }
                
            case .newWorkoutAdded(let workout):
                /*
                 for now I'm adding a workout directly instead of full refresh of all workouts including
                 favorite ids sync. It's an add feature = if all went well, this workout is the last one
                 in the array of workouts even in provider. If something went wrong, this action is not
                 even called = no new workout will be added = the state.workouts equals privder's workours array
                 If all went ok, both workouts arrays are equal even when adding workout manualy without syncing
                */
                state.workouts.append(workout)
                state.workoutToAdd = nil
                return .none
                
            case .onDeleteTriggered(let indexSet):
                var ids: [(UUID, Bool)] = []
                
                indexSet.forEach {
                    if $0 < state.workouts.count {
                        let workout = state.workouts[$0]
                        
                        ids.append((workout.id, workout.isStoredOnThisDevice))
                    }
                }
                
                for workoutId in ids {
                    state.workouts.removeAll { $0.id == workoutId.0 }
                    state.favorites.remove(workoutId.0)
                }
                
                environment.workoutsProvider.removeWorkouts(ids)
                
                return .none
                
            case .filterChanged(let selection):
                state.storageFilter = selection
                return .none
                
            case .workout(id: _, action: .favoriteAdded(let favoriteId)):
                state.favorites.insert(favoriteId)
                return .none

            case .workout(id: _, action: .favoriteRemoved(let favoriteId)):
                state.favorites.remove(favoriteId)
                return .none

            case .workout(id: _, action: _), .addWorkout(_):
                return .none
            }
        }
)

let workoutsStore = Store<WorkoutsState, WorkoutsAction>(
    initialState: WorkoutsState(),
    reducer: workoutsReducer,
    environment: WorkoutsEnvironment(
        workoutsProvider: ProxyWorkoutsProvider(
            onDeviceWorkoutsProvider: CoreDataWorkoutsProvider(),
            remoteWorkoutsProvider: FirebaseWorkoutsProvider()
        ),
        favoritesProvider: UserDefaultsFavoritesProvider()
    )
)
