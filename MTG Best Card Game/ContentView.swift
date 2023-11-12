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
    var foil: Bool?
    var legalities: Legalities?

    
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case name
        case imageUris = "image_uris"
        case legalities = "legalities"
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
    var standard: String
    var future: String
    var historic : String
    var gladiator: String
    var pioneer: String
    var explorer: String
    var modern: String
    var legacy: String
    var pauper: String
    var vintage: String
    var penny: String
    var commander: String
    var oathbreaker:String
    var brawl: String
    var historicbrawl: String
    var alchemy: String
    var paupercommander: String
    var duel: String
    var oldschool: String
    var premodern: String
    var predh: String
    var allLegalities: [(format: String, legality: String)] {
            return [
                ("Standard", standard),
                ("Future", future),
                ("Historic", historic),
                ("Gladiator", gladiator),
                ("Pioneer", pioneer),
                ("Explorer", explorer),
                ("Modern", modern),
                ("Legacy", legacy),
                ("Pauper", pauper),
                ("Vintage", vintage),
                ("Penny", penny),
                ("Commander", commander),
                ("Oathbreaker", oathbreaker),
                ("Brawl", brawl),
                ("HistoricBrawl", historicbrawl),
                ("Alchemy", alchemy),
                ("PauperCommander", paupercommander),
                ("Duel", duel),
                ("OldSchool", oldschool),
                ("Premodern", premodern),
                ("Predh", predh)
            ]
        }
    
    enum CodingKeys: String, CodingKey {
        case standard
        case future
        case historic
        case gladiator
        case pioneer
        case explorer
        case modern
        case legacy
        case pauper
        case vintage
        case penny
        case commander
        case oathbreaker
        case brawl
        case historicbrawl
        case alchemy
        case paupercommander
        case duel
        case oldschool
        case premodern
        case predh
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
                                        .frame(width: 100).foregroundColor(.black)
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
struct LegalityView: View {
    var legality: (status: String, format: String)
    
    var body: some View {
        HStack {
            Text(legality.status)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(legality.status == "legal" ? Color.green : Color.red)
                .cornerRadius(5)
            Text(legality.format)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading) // This ensures the text is left-aligned
        }
    }
}

struct CardLegalitiesView: View {
    let legalities: [(status: String, format: String)]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(legalities, id: \.format) { legality in
                LegalityView(legality: legality)
            }
        }
        .padding(.horizontal)
    }
}
let sampleLegalities = [
        (status: "legal", format: "Legacy"),
        (status: "not_legal", format: "Standard"),
        // Add all other legalities here
    ]
struct CardDetailView: View {
    @Environment(\.presentationMode) var presentationMode

    let card: Card
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) { // Remove any default space between the views
                // Image that fills the top part of the screen, including the safe area
                if let artCropURL = card.imageUris?.artCrop {
                    AsyncImage(url: artCropURL) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top + (geometry.size.width * 0.25)) // 1/4 of the width + safe area
                             .clipped()
                             .edgesIgnoringSafeArea(.top)
                    } placeholder: {
                        Color.gray
                    }
                }
                // Card details
                VStack(alignment: .leading) { // Reduced spacing and padding around text
                    Text(card.name)
                        .font(.system(size: 19))
                        .fontWeight(.semibold)
                    
                    Text(card.typeLine)
                        .font(.system(size: 18))
                        .foregroundColor(.black).fontWeight(.semibold)
                    
                    if let oracleText = card.oracleText {
                        Text(oracleText.replacingOccurrences(of: "\n", with: "\n\n"))
                            .font(.system(size: 16))
                    }
                }
                .padding([.horizontal, .bottom]) // Apply padding only to the sides and bottom
                .background(Color.white)
                .cornerRadius(10)
                .offset(y: -geometry.safeAreaInsets.top) // Align the text block to the bottom edge of the image
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 6)
                
                CardLegalitiesView(legalities: sampleLegalities)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
                .navigationBarBackButtonHidden(true) // Hide the default back button
                    .navigationBarItems(leading: backButton)
    }
    var backButton: some View {
           Button(action: {
               self.presentationMode.wrappedValue.dismiss()
           }) {
               Image(systemName: "chevron.left") // Use chevron for "<" arrow shape
                   .foregroundColor(.white)
                   .imageScale(.large) // Increase the size if needed
           }
       }
}


#Preview {
    ContentView()
}
