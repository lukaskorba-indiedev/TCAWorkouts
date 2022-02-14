import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: Store<FavoritesState, FavoritesAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    if viewStore.favorites.isEmpty {
                        Text("here you'll see all your favorites")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEachStore(
                                store.scope(
                                    state: { $0.favoriteWorkouts },
                                    action: FavoritesAction.workout(id:action:)
                                ),
                                content: { workoutStore in
                                    WithViewStore(workoutStore) { workoutViewStore in
                                        WorkoutItemView(store: workoutStore)
                                    }
                                })
                        }
                    }
                }
                .navigationTitle("Favorites")
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(store: favoritesStore)
    }
}
