import Foundation
import ComposableArchitecture

struct FavoritesState: Equatable {
    // app state
    var workouts = IdentifiedArrayOf<Workout>()
    var favorites = Set<UUID>()
}

enum FavoritesAction: Equatable {
    case onAppear
    case workout(id: UUID, action: WorkoutAction)
}

struct FavoritesEnvironment {
    let workoutsProvider: WorkoutsProvider
    let favoritesProvider: FavoritesProvider
}

let favoritesReducer = Reducer<FavoritesState, FavoritesAction, FavoritesEnvironment>.combine(
    workoutReducer.forEach(
        state: \.workouts,
        action: /FavoritesAction.workout(id:action:),
        environment: { environment in
            WorkoutEnvironment(favoritesProvider: environment.favoritesProvider)
        }
    ),
    
        .init{ state, action, environment in
            switch action {

            case .onAppear:
                return .none
                
            case .workout(id: _, action: .favoriteAdded(let favoriteId)):
                state.favorites.insert(favoriteId)
                return .none

            case .workout(id: _, action: .favoriteRemoved(let favoriteId)):
                state.favorites.remove(favoriteId)
                return .none

            case .workout(id: _, action: _):
                return .none
            }
        }
)
    
let favoritesStore = Store<FavoritesState, FavoritesAction>(
    initialState: FavoritesState(),
    reducer: favoritesReducer,
    environment: FavoritesEnvironment(
        workoutsProvider: ProxyWorkoutsProvider(
            onDeviceWorkoutsProvider: CoreDataWorkoutsProvider(),
            remoteWorkoutsProvider: FirebaseWorkoutsProvider()
        ),
        favoritesProvider: UserDefaultsFavoritesProvider()
    )
)
