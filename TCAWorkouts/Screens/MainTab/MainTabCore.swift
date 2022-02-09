import ComposableArchitecture

struct MainState: Equatable {
    // app state
    var workouts = IdentifiedArrayOf<Workout>()
    var favorites = Set<UUID>()

    // domain states
    var workoutsState = WorkoutsState()
    var favoritesState = FavoritesState()
    
    // navigation
    var selectedTab = Tab.workout
    
    enum Tab {
        case workout
        case favorites
    }
}

extension MainState {
    // domain states
    var workoutsComposedState: WorkoutsState {
        get {
            var newState = workoutsState
            newState.workouts = workouts
            newState.favorites = favorites
            
            return newState
        }
        set {
            self.workoutsState = newValue
            self.workouts = newValue.workouts
            self.favorites = newValue.favorites
        }
    }

    var favoritesComposedState: FavoritesState {
        get {
            var newState = favoritesState
            newState.workouts = workouts
            newState.favorites = favorites
            
            return newState
        }
        set {
            self.favoritesState = newValue
            self.workouts = newValue.workouts
            self.favorites = newValue.favorites
        }
    }
}

enum MainAction: Equatable {
    // app actions
    case loadWorkouts
    case loadedWorkouts([Workout])

    // domain action
    case workouts(WorkoutsAction)
    case favorites(FavoritesAction)
    case tabChanged(MainState.Tab)
}

struct MainEnvironment {
    let workoutsProvider: WorkoutsProvider
    let favoritesProvider: FavoritesProvider
}

let mainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
    workoutsReducer.pullback(
        state: \MainState.workoutsComposedState,
        action: /MainAction.workouts,
        environment: { environment in
            WorkoutsEnvironment(
                workoutsProvider: environment.workoutsProvider,
                favoritesProvider: environment.favoritesProvider
            )
        }),

    favoritesReducer.pullback(
        state: \MainState.favoritesComposedState,
        action: /MainAction.favorites,
        environment: { environment in
            FavoritesEnvironment(
                workoutsProvider: environment.workoutsProvider,
                favoritesProvider: environment.favoritesProvider

            )
        }),
    
        .init { state, action, environment in
            switch action {
                
            case .loadWorkouts:
                if !state.workouts.isEmpty {
                    return .none
                }
                
                return environment.workoutsProvider.getWorkouts(.all)
                    .map(MainAction.loadedWorkouts)
                
            case .loadedWorkouts(let workouts):
                workouts.forEach { state.workouts.append($0) }
                
                state.workouts.sort { lhs, rhs in
                    lhs.timestemp > rhs.timestemp
                }

                return .none

            case .favorites(_), .workouts(_):
                return .none
            
            case .tabChanged(let newRoute):
                state.selectedTab = newRoute
                return .none
            }
        }
)

let mainStore = Store<MainState, MainAction>(
    initialState: MainState(),
    reducer: mainReducer,
    environment: MainEnvironment(
        workoutsProvider: ProxyWorkoutsProvider(
            onDeviceWorkoutsProvider: CoreDataWorkoutsProvider(),
            remoteWorkoutsProvider: FirebaseWorkoutsProvider()
        ),
        favoritesProvider: UserDefaultsFavoritesProvider()
    )
)
