import SwiftUI
import ComposableArchitecture

struct AddWorkoutView: View {
    let store: Store<Workout?, AddWorkoutAction>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button("change") {
                    viewStore.send(.changeNameOfWorkout)
                }
                .padding()
                Button("remote") {
                    viewStore.send(.changeToRemote)
                }
                .padding()
                Text("Hello, World!")
            }
            .navigationTitle("Add New Workout")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("cancel", action: {
                    viewStore.send(.discardAndClose)
                }),
                trailing: Button("save", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
}

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView(store: addWorkoutStore)
    }
}
