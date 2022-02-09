import Foundation
import ComposableArchitecture

protocol FavoritesProvider {
    func getFavorites() -> Effect<[UUID], Never>
    func addFavorite(_ id: UUID) -> Effect<UUID, Never>
    func removeFavorite(_ id: UUID) -> Effect<UUID, Never>
    func favoriteToggled(id: UUID, newState: Bool) -> Effect<UUID, Never>
}

