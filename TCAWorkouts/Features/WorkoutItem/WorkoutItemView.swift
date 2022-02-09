import SwiftUI
import ComposableArchitecture

struct WorkoutItemView: View {
    let store: Store<Workout, WorkoutAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text("\(viewStore.name)")
                        .fontWeight(.heavy)
                    Spacer()
                    Button {
                        viewStore.send(.toggleFavoriteTapped)
                    } label: {
                        Image(systemName: viewStore.isFavorite ? "heart.fill" : "heart")
                    }
                }
                .padding(2)
                HStack {
                    Image(systemName: viewStore.isStoredOnThisDevice ? "iphone" : "cloud")
                        .foregroundColor(viewStore.isStoredOnThisDevice ? .green : .blue)
                    Text("in ").fontWeight(.thin) +
                    Text("\(viewStore.place) ") +
                    Text("time ").fontWeight(.thin) +
                    Text("\(viewStore.duration.durationFormated())")
                    Spacer()
                }
                .padding(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkoutItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                WorkoutItemView(store: workoutStore)
            }
            .listStyle(DefaultListStyle())
        }
    }
}
