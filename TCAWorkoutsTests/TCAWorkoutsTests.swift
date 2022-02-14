import XCTest
@testable import TCAWorkouts
import ComposableArchitecture

class TCAWorkoutsTests: XCTestCase {
    func testToggleFavorite() throws {
        let testStore = TestStore(
            initialState: Workout(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
            reducer: workoutReducer,
            environment: WorkoutEnvironment(
                favoritesProvider: UserDefaultsFavoritesProvider())
        )

        testStore.send(.toggleFavoriteTapped) { $0.isFavorite = true }
        
        testStore.receive(.favoriteAdded(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)) {
            $0.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }

        testStore.send(.toggleFavoriteTapped) { $0.isFavorite = false }
        
        testStore.receive(.favoriteRemoved(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)) {
            $0.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
    
    func testWorkoutComputedProperties() throws {
    }
}
