import Foundation
import ComposableArchitecture

class UserDefaultsFavoritesProvider: FavoritesProvider {
    fileprivate var favorites: [UUID] = []
    
    func getFavorites() -> Effect<[UUID], Never> {
        return .init(value: favorites)
    }
    
    func addFavorite(_ id: UUID) -> Effect<UUID, Never> {
        favorites.append(id)
        
        return .init(value: id)
    }
    
    func removeFavorite(_ id: UUID) -> Effect<UUID, Never> {
        favorites.removeAll { $0 == id }
        
        return .init(value: id)
    }

    func favoriteToggled(id: UUID, newState: Bool) -> Effect<UUID, Never> {
        if newState {
            return addFavorite(id)
        } else {
            return removeFavorite(id)
        }
    }
}
