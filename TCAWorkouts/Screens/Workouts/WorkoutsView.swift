import SwiftUI
import ComposableArchitecture
import CryptoKit

struct WorkoutsView: View {
    let store: Store<WorkoutsState, WorkoutsAction>
    @State private var favoriteColor = Storage.all
    
//    @State private var favoriteColor = "Red"
//    var colors = ["Red", "Green", "Blue"]
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Picker("Where do you want to stare the workout?", selection:
                            viewStore.binding(
                        get: { $0.storageFilter },
                        send: WorkoutsAction.filterChanged)
                    ) {
                        ForEach(Storage.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(5)
                    
                    List {
                        ForEachStore(
                            store.scope(
                                state: { $0.workouts },
                                action: WorkoutsAction.workout(id:action:)
                            ),
                            content: { workoutStore in
                                WithViewStore(workoutStore) { workoutViewStore in
                                    if viewStore.storageFilter == .all ||
                                        (viewStore.storageFilter == .onDevice && workoutViewStore.isStoredOnThisDevice) ||
                                        (viewStore.storageFilter == .remote && !workoutViewStore.isStoredOnThisDevice) {
                                        WorkoutItemView(store: workoutStore)
                                    }
                                }
                            })
                            .onDelete { viewStore.send(.onDeleteTriggered($0)) }
                    }
                    .refreshable {
                        viewStore.send(.pullToRefreshTriggered)
                    }
                }
                .navigationBarTitle("Workouts", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        NavigationLink(
                            wrapper: viewStore.workoutToAdd,
                            on: { viewStore.send(.addWorkoutTapped) },
                            off: { viewStore.send(.dismissAndSaveWorkout) },
                            destination: {
                                AddWorkoutView(store: store.scope(
                                    state: \.workoutToAdd,
                                    action: WorkoutsAction.addWorkout)
                                )
                            },
                            label: {
                                Image(systemName: "folder.badge.plus")
                            })
                )
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
        }
    }
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(store: workoutsStore)
    }
}
