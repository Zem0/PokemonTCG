import Foundation

struct PokemonCard: Codable {
    let id: String
    let artist: String?
    let name: String
    let number: String
    let images: PokemonCardImages
    let rarity: String?
    let set: PokemonSet
}

struct PokemonCardImages: Codable {
    let small: String
    let large: String
}

struct PokemonSet: Codable {
    let id: String
    let name: String
    let releaseDate: String
    let series: String
    let images: SetImages
}

struct SetImages: Codable {
    let symbol: String
    let logo: String
}

class NetworkManager: ObservableObject {
    @Published var pokemonCardImageURL: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentCardArtist: String? = nil
    @Published var currentCardName: String? = nil
    @Published var currentCardNumber: String? = nil
    @Published var currentCardId: String? = nil
    @Published var currentCardRarity: String? = nil
    @Published var currentSetName: String? = nil
    @Published var currentSetReleaseDate: String? = nil
    @Published var currentSetSeries: String? = nil
    @Published var currentSetSymbolURL: String? = nil
    @Published var currentSetLogoURL: String? = nil
    
    private let baseURL = "https://api.pokemontcg.io/v2/cards"
    private let apiKey = "03c59aab-400f-4635-89ab-caf237f511b5"

    func fetchRandomPokemonCard() {
        let randomPage = Int.random(in: 1...10000)
        
        guard let url = URL(string: "\(baseURL)?page=\(randomPage)&pageSize=1") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data returned from API."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]],
                       let firstCard = dataArray.first {
                        let cardData = try JSONSerialization.data(withJSONObject: firstCard)
                        let card = try JSONDecoder().decode(PokemonCard.self, from: cardData)
                        
                        self.pokemonCardImageURL = card.images.large
                        self.currentCardArtist = card.artist
                        self.currentCardNumber = card.number
                        self.currentCardRarity = card.rarity
                        self.currentCardName = card.name
                        self.currentCardId = card.id
                        self.currentSetName = card.set.name
                        self.currentSetSeries = card.set.series
                        self.currentSetReleaseDate = card.set.releaseDate
                        self.currentSetSymbolURL = card.set.images.symbol
                        self.currentSetLogoURL = card.set.images.logo
                    } else {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure"])
                    }
                } catch {
                    self.errorMessage = "Error decoding Pokémon card data: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }
        task.resume()
    }
}
