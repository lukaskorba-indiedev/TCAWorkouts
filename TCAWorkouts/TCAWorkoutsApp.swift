import SwiftUI

@main
struct TCAWorkoutsApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(store: mainStore)
        }
    }
}
