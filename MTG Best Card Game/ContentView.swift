import SwiftUI

// Define the Codable structs to map the JSON structure
struct CardList: Codable {
    var object: String
    var totalCards: Int
    var hasMore: Bool
    var data: [Card]
    
    enum CodingKeys: String, CodingKey {
        case object
        case totalCards = "total_cards"
        case hasMore = "has_more"
        case data
    }
}

struct Card: Codable {
    var object: String
    var id: String
    var name: String
    var imageUris: ImageUris?
    var manaCost: String?
    var typeLine: String
    var oracleText: String?
    var colors: [String]?
    var prices: Prices?
    var foil: Bool? // Add this line to include the foil property

    
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case name
        case imageUris = "image_uris"
        case manaCost = "mana_cost"
        case typeLine = "type_line"
        case oracleText = "oracle_text"
        case colors
        case foil
    }
}
struct Prices: Codable {
    var usd: String?
    var usdFoil: String?
    
    enum CodingKeys: String, CodingKey {
        case usd
        case usdFoil = "usd_foil"
    }
}
struct Legalities: Codable {
    var small: String
    var normal: String
    var large:String
    var png: String
    var artCrop: String
    var borderCrop: String
    
    enum CodingKeys: String, CodingKey {
        case small
        case normal
        case large
        case png
        case artCrop = "art_crop"
        case borderCrop = "border_crop"
    }
}
struct ImageUris: Codable {
    var small: URL
    var normal: URL
    var large: URL?
    var png: URL?
    var artCrop: URL?
    var borderCrop: URL?
    
    enum CodingKeys: String, CodingKey {
        case small
        case normal
        case large
        case png
        case artCrop = "art_crop"
        case borderCrop = "border_crop"
    }
}

// SwiftUI View that displays the cards
struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var searchText = ""
    @State private var sortAlphabetically = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Search bar
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Sort button
                    Button(action: {
                        sortAlphabetically.toggle()
                    }) {
                        Image(systemName: sortAlphabetically ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                    }
                    .padding(.trailing)
                }
                
                ScrollView {
                    var filteredAndSortedCards: [Card] {
                        var filteredCards = cards
                        
                        if !searchText.isEmpty {
                            filteredCards = filteredCards.filter { card in
                                card.name.localizedCaseInsensitiveContains(searchText)
                            }
                        }
                        
                        if sortAlphabetically {
                            return filteredCards.sorted { $0.name < $1.name }
                        } else {
                            return filteredCards
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredAndSortedCards, id: \.id) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                VStack {
                                    CardImageView(card: card)
                                    Text(card.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .frame(width: 100)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Cards")
            }
            .onAppear(perform: loadCards)
        }
    }
    // Function to load and parse the JSON data
    func loadCards() {
        // Replace this with the actual path to your JSON file in the app bundle
        if let url = Bundle.main.url(forResource: "WOT-Scryfall", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            do {
                let cardList = try decoder.decode(CardList.self, from: data)
                self.cards = cardList.data
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
    }
}
struct CardImageView: View {
    let card: Card

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
            if let imageUris = card.imageUris {
                AsyncImage(url: imageUris.normal) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.frame(width: 100, height: 140)
                }
                .frame(width: 100, height: 140)
                .cornerRadius(5)

                if card.foil == true{
                    Text("F")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(4)
                        .background(Color.yellow.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(3)
                        .padding([.bottom, .leading], 4)
                }
            }
        }
    }
}

struct CardDetailView: View {
    let card: Card

    var body: some View {
        ScrollView {
            VStack {
                // Display the card image (you can reuse the CardImageView here)
                CardImageView(card: card)
                    .padding()
                
                Text(card.name)
                    .font(.title)
                    .padding()
                
                Text(card.typeLine)
                    .font(.subheadline)
                    .padding()
                
                Text(card.oracleText ?? "")
                    .font(.body)
                    .padding()
                
                // Display legalities (assuming you have a Legalities struct in your data)
//                ForEach(card.legalities ?? [], id: \.format) { legality in
//                    Text("\(legality.format): \(legality.legality)")
//                        .font(.subheadline)
//                        .padding()
//                }
                
                Spacer()
            }
        }
        .navigationTitle("Card Details")
    }
}
#Preview {
    ContentView()
}
