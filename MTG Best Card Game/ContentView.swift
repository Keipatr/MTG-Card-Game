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
    var rank: Int
    
    
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
        case prices = "prices"
        case rank = "edhrec_rank"
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
            ("Historic Brawl", historicbrawl),
            ("Alchemy", alchemy),
            ("Pauper Commander", paupercommander),
            ("Duel", duel),
            ("Old School", oldschool),
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

enum SortingOption: String, CaseIterable {
    case alphabetically = "Alphabetically"
    case byRank = "By Rank"
    case clear = "Clear Sorting"
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var searchText = ""
    @State private var isSortingOptionsSheetPresented = false
    @State private var selectedSortingOption: SortingOption? = nil
    @State private var currentIndex = 0
    
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
                        isSortingOptionsSheetPresented.toggle()
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                    
                    .actionSheet(isPresented: $isSortingOptionsSheetPresented) {
                        ActionSheet(
                            title: Text("Sort Options"),
                            buttons: SortingOption.allCases.map { option in
                                    .default(Text(option.rawValue)) {
                                        if option == selectedSortingOption {
                                            selectedSortingOption = nil
                                        } else {
                                            selectedSortingOption = option
                                        }
                                    }
                            }
                        )
                    }
                    Text(selectedSortingOption?.rawValue ?? "No Sorting").padding(.trailing,25)
                    
                }
                
                ScrollView {
                    var filteredAndSortedCards: [Card] {
                        var filteredCards = cards
                        
                        if !searchText.isEmpty {
                            filteredCards = filteredCards.filter { card in
                                card.name.localizedCaseInsensitiveContains(searchText)
                            }
                        }
                        
                        switch selectedSortingOption {
                        case .alphabetically?:
                            return filteredCards.sorted { $0.name < $1.name }
                        case .byRank?:
                            return filteredCards.sorted { $0.rank < $1.rank }
                        default:
                            return filteredCards
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredAndSortedCards, id: \.id) { card in
                            NavigationLink(destination: CardDetailView(card: card, currentIndex: $currentIndex, cards: filteredAndSortedCards)) {
                                VStack {
                                    CardImageView(card: card)
                                    Text(card.name)
                                        .font(.caption)
                                        .lineLimit(1).multilineTextAlignment(.center)
                                        .frame(width: 100).foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Magic The Gathering")
                .toolbarColorScheme(.dark, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline).toolbarBackground(
                    Color(red: 44 / 255, green: 61 / 255, blue: 81 / 255),
                    for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
            .onAppear(perform: loadCards)
        }
    }
    // Function to load and parse the JSON data
    func loadCards() {
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
                
                HStack(spacing: 4) {
                    if card.foil == true {
                        Text("F")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(4)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    if let price = card.prices?.usdFoil ?? card.prices?.usd {
                        Text("$\(price)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(9)
                .padding([.bottom, .leading], 4)
            }
        }
    }
}

struct CardDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let card: Card
    @Binding var currentIndex: Int
    let cards: [Card]
    var body: some View {
        let card = cards[currentIndex]
        GeometryReader { geometry in
            ScrollView{
                VStack(spacing: 10)
                {
                    VStack(alignment: .leading) {
                        if let artCropURL = card.imageUris?.artCrop {
                            AsyncImage(url: artCropURL) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top + (geometry.size.width * 0.6))
                                    .clipped()
                                    .edgesIgnoringSafeArea(.top)
                            } placeholder: {
                                Color.gray
                            }.edgesIgnoringSafeArea(.top)
                        }
                        Text(card.name)
                            .font(.system(size: 19))
                            .fontWeight(.semibold).padding(.horizontal,10).padding(.top,10)
                        
                        Text(card.typeLine)
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .fontWeight(.semibold).padding(.horizontal, 10)
                        
                        if let oracleText = card.oracleText {
                            Text(oracleText.replacingOccurrences(of: "\n", with: "\n\n"))
                                .font(.system(size: 16)).padding(.horizontal, 10).padding(.bottom,14)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }.frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .offset(y: -geometry.safeAreaInsets.top)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 6)
                    
                    // Legalities section
                    VStack(alignment: .leading) {
                        HStack {
                            if currentIndex > 0 {
                                Button(action: swipeRight) {
                                    Image(systemName: "arrow.left.circle")
                                        .imageScale(.large)
                                }
                            } else {
                                Image(systemName: "arrow.left.circle")
                                    .imageScale(.large)
                                    .opacity(0)
                            }
                            
                            Text("Legalities")
                                .font(.headline)
                            
                            if currentIndex < cards.count - 1 {
                                Button(action: swipeLeft) {
                                    Image(systemName: "arrow.right.circle")
                                        .imageScale(.large)
                                }
                            } else {
                                Image(systemName: "arrow.right.circle")
                                    .imageScale(.large)
                                    .opacity(0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        if let legalities = card.legalities {
                            let gameTypes = legalities.allLegalities
                            if !gameTypes.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(gameTypes, id: \.format) { gameType in
                                        let isLegal = gameType.legality == "legal"
                                        let boxColor = isLegal ? Color.green : Color.gray
                                        let text = isLegal ? "Legal" : "Not Legal"
                                        
                                        HStack {
                                            Text(text).font(.system(size: 14)).frame(width: 65)
                                                .padding(10)
                                                .background(RoundedRectangle(cornerRadius: 10).fill(boxColor))
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity, minHeight: 40)
                                                .alignmentGuide(.leading) { _ in 0 }
                                            
                                            Text(gameType.format)
                                                .font(.system(size: 14))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }.padding(.horizontal,8)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 5)
                                    }
                                }
                            }
                            
                        }
                    }
                    .offset(y: -geometry.safeAreaInsets.top)
                }
            }
            
            .gesture(DragGesture().onEnded(handleSwipe))
            .edgesIgnoringSafeArea(.top)
            
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            
        }
        
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let swipeDistance = value.translation.width
        
        if swipeDistance < -50 {
            swipeLeft()
        } else if swipeDistance > 50 {
            swipeRight()
        }
    }
    
    private func swipeLeft() {
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            print("Moved to next card: Index \(currentIndex)")
        } else {
            print("No more cards on the left")
        }
    }
    
    private func swipeRight() {
        if currentIndex > 0 {
            currentIndex -= 1
            print("Moved to previous card: Index \(currentIndex)")
        } else {
            print("No more cards on the right")
        }
    }
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
                .imageScale(.large)
        }
    }
}



#Preview {
    ContentView()
}
