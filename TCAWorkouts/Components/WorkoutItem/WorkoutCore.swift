import Foundation
import SwiftUI
import ComposableArchitecture

extension Int {
    func durationFormated() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short

        if let formattedString = formatter.string(from: TimeInterval(self * 60)) {
            return formattedString
        } else {
            return ""
        }
    }
}

struct Workout: Equatable, Identifiable {
    var name = ""
    var place = ""
    var duration = 0
    var isFavorite = false
    var isStoredOnThisDevice = true
    var timestemp: TimeInterval = 0

    var id = UUID()
}

enum WorkoutAction: Equatable {
    case toggleFavoriteTapped
    case favoriteAdded(UUID)
    case favoriteRemoved(UUID)
}

struct WorkoutEnvironment {
    let favoritesProvider: FavoritesProvider
}

let workoutReducer = Reducer<Workout, WorkoutAction, WorkoutEnvironment> { state, action, environment in
    switch action {
        
    case .toggleFavoriteTapped:
        state.isFavorite.toggle()
        
        return environment.favoritesProvider.favoriteToggled(id: state.id, newState: state.isFavorite)
            .map( state.isFavorite ? WorkoutAction.favoriteAdded : WorkoutAction.favoriteRemoved)
        
    case .favoriteAdded(let favoriteId):
        return .none

    case .favoriteRemoved(let favoriteId):
        return .none

    }
}

let workoutStore = Store<Workout, WorkoutAction>(
    initialState: Workout(name: "<new workout>"),
    reducer: workoutReducer,
    environment:WorkoutEnvironment(favoritesProvider: UserDefaultsFavoritesProvider()))
