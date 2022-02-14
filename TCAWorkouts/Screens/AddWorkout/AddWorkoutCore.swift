import ComposableArchitecture

struct AddWorkoutState: Equatable {
    var title = ""
}

enum AddWorkoutAction: Equatable {
    case changeNameOfWorkout
    case changeToRemote
    case discardAndClose
    case workoutTitleChanged(String)
}

let addWorkoutReducer = Reducer<Workout?, AddWorkoutAction, Void> { state, action, _ in
    switch action {
        
    case .changeNameOfWorkout:
        //state.name = "parada"
        
        return .none

    case .changeToRemote:
        //state?.isStoredOnThisDevice = false
        
        return .none

    case .discardAndClose:
        //state = nil
        
        return .none
        
    case .workoutTitleChanged(let newTitle):
        return .none
    }
}

let addWorkoutStore: Store<Workout?, AddWorkoutAction> = .init(
    initialState: nil,
    reducer: addWorkoutReducer,
    environment: ())
