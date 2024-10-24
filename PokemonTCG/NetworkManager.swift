import Foundation

struct PokemonCard: Codable {
    let id: String
    let name: String
    let images: PokemonCardImages
}

struct PokemonCardImages: Codable {
    let small: String
    let large: String
}

class NetworkManager: ObservableObject {
    @Published var pokemonCardImageURL: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentCardName: String? = nil
    @Published var currentCardId: String? = nil
    
    private let baseURL = "https://api.pokemontcg.io/v2/cards"
    private let apiKey = "03c59aab-400f-4635-89ab-caf237f511b5"

    func fetchRandomPokemonCard() {
        // Generate a random page number (assuming there are about 10000 cards in the database)
        let randomPage = Int.random(in: 1...10000)
        
        guard let url = URL(string: "\(baseURL)?page=\(randomPage)&pageSize=1") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        print("Fetching Pokémon card from: \(url)")

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data returned from API."
                    return
                }
                
                // Print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }

                do {
                    // First, try to decode as a dictionary
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]],
                       let firstCard = dataArray.first {
                        // Now try to decode the first card
                        let cardData = try JSONSerialization.data(withJSONObject: firstCard)
                        let card = try JSONDecoder().decode(PokemonCard.self, from: cardData)
                        self.pokemonCardImageURL = card.images.large
                        self.currentCardName = card.name
                        self.currentCardId = card.id
                        print("Fetched Pokémon card image: \(self.pokemonCardImageURL ?? "None")")
                        print("Card Name: \(card.name), ID: \(card.id)")
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
