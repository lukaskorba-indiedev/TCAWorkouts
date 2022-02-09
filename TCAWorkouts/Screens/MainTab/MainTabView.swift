import SwiftUI
import ComposableArchitecture

struct MainTabView: View {
    let store: Store<MainState, MainAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0.selectedTab },
                send: MainAction.tabChanged)
            ) {
                WorkoutsView(store: store.scope(
                    state: { $0.workoutsState },
                    action: MainAction.workouts)
                )
                    .tabItem({
                        Image(systemName: "folder")
                        Text("Workouts")
                    })
                    .tag(MainState.Tab.workout)
                
                FavoritesView(store: store.scope(
                    state: { $0.favoritesState },
                    action: MainAction.favorites)
                                )
                    .tabItem({
                        Image(systemName: "heart")
                        Text("Favorites")
                    })
                    .tag(MainState.Tab.favorites)
            }
            .onAppear(perform: { viewStore.send(.loadWorkouts) })
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(store: mainStore)
    }
}
