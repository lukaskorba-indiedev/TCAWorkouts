import ComposableArchitecture

enum AddWorkoutAction: Equatable {
    case changeNameOfWorkout
    case changeToRemote
    case discardAndClose
}

let addWorkoutReducer = Reducer<Workout?, AddWorkoutAction, Void> { state, action, _ in
    switch action {
        
    case .changeNameOfWorkout:
        state?.name = "parada"
        
        return .none

    case .changeToRemote:
        state?.isStoredOnThisDevice = false
        
        return .none

    case .discardAndClose:
        state = nil
        
        return .none
    }
}

let addWorkoutStore: Store<Workout?, AddWorkoutAction> = .init(
    initialState: nil,
    reducer: addWorkoutReducer,
    environment: ())
