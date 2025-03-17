//
//  SearchInterestVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 02/03/2025.
//

import UIKit
import Alamofire

class SearchInterestVC: MainViewController {

    let userInterestsAndHobbies: [String] = [
        "Photography", "Travel", "Cooking", "Hiking", "Reading", "Writing", "Painting", "Drawing", "Sculpting", "Music",
        "Guitar", "Piano", "Violin", "Singing", "Dancing", "Ballet", "Hip-Hop", "Jazz", "Yoga", "Meditation",
        "Fitness", "Weightlifting", "Running", "Cycling", "Swimming", "Basketball", "Football", "Soccer", "Tennis",
        "Volleyball", "Badminton", "Table Tennis", "Gaming", "Video Games", "Board Games", "Card Games", "Chess",
        "Coding", "Programming", "Web Development", "App Development", "Data Science", "Artificial Intelligence",
        "Machine Learning", "Robotics", "Astronomy", "Astrophysics", "Cosmology", "Biology", "Chemistry", "Physics",
        "Mathematics", "History", "Archaeology", "Anthropology", "Psychology", "Sociology", "Philosophy", "Literature",
        "Poetry", "Film", "Theater", "Acting", "Directing", "Screenwriting", "Animation", "Graphic Design", "Illustration",
        "Fashion", "Interior Design", "Gardening", "Botany", "Birdwatching", "Fishing", "Hunting", "Camping", "Backpacking",
        "Rock Climbing", "Kayaking", "Surfing", "Sailing", "Snowboarding", "Skiing", "Skateboarding", "Collecting",
        "Coin Collecting", "Stamp Collecting", "Model Building", "Woodworking", "Metalworking", "Pottery", "Ceramics",
        "Embroidery", "Knitting", "Crocheting", "Sewing", "Quilting", "Baking", "Brewing", "Winemaking", "Mixology",
        "Calligraphy", "Origami", "Juggling", "Magic", "Public Speaking", "Debating", "Volunteering", "Charity Work",
        "Mentoring", "Teaching", "Learning Languages", "Foreign Languages", "Cultural Studies", "Genealogy",
        "DIY Projects", "Home Improvement", "Electronics", "Gadgets", "Technology", "Startups", "Entrepreneurship",
        "Investing", "Finance", "Cryptocurrency", "Blockchain", "Sustainable Living", "Environmentalism", "Veganism",
        "Vegetarianism", "Paleo Diet", "Keto Diet", "Mindfulness", "Personal Development", "Self-Improvement", "Travel Photography",
        "Landscape Photography", "Portrait Photography", "Street Photography", "Wildlife Photography", "Food Photography",
        "Macro Photography", "Astrophotography", "Digital Art", "Pixel Art", "Vector Art", "3D Modeling", "Game Development",
        "Mobile Games", "Console Games", "PC Games", "Indie Games", "Esports", "Game Design", "Data Analysis",
        "Cloud Computing", "Cybersecurity", "Network Security", "Ethical Hacking", "Quantum Computing", "Nanotechnology",
        "Genetics", "Neuroscience", "Cognitive Science", "Political Science", "Economics", "Linguistics", "Creative Writing",
        "Science Fiction", "Fantasy", "Horror", "Mystery", "Thriller", "Comedy", "Drama", "Documentaries", "Independent Films",
        "Foreign Films", "Musical Theatre", "Improv", "Scenic Design", "Costume Design", "Fashion Design", "Textile Design",
        "Floral Design", "Urban Gardening", "Permaculture", "Aquaponics", "Mycology", "Ornithology", "Entomology",
        "Fly Fishing", "Bow Hunting", "Wilderness Survival", "Caving", "Rafting", "Windsurfing", "Kitesurfing", "Mountain Biking",
        "Longboarding", "Parkour", "Freerunning", "Antiquing", "Vinyl Collecting", "Comic Book Collecting", "Toy Collecting",
        "Scale Modeling", "Blacksmithing", "Glassblowing", "Leatherworking", "Tapestry", "Needlepoint", "Macrame",
        "Confectionery", "Distilling", "Cider Making", "Bartending", "Hand Lettering", "Papercraft", "Stage Magic",
        "Close-up Magic", "Rhetoric", "Forensics", "Community Outreach", "Social Justice", "Educational Technology",
        "Second Language Acquisition", "Family History", "Home Brewing", "Smart Home Technology", "Consumer Electronics",
        "Fintech", "Alternative Energy", "Zero Waste", "Plant-Based Diet", "Intermittent Fasting", "Stoicism", "Human Psychology",
        "Digital Marketing", "Social Media Marketing", "Content Creation", "SEO", "UX Design", "UI Design", "Product Design",
        "Agile Development", "Scrum", "DevOps", "Data Visualization", "Big Data", "Natural Language Processing",
        "Computer Vision", "Deep Learning", "Quantum Physics", "Particle Physics", "Evolutionary Biology", "Cognitive Psychology",
        "Behavioral Economics", "Semiotics", "Narrative Theory", "Experimental Film", "Avant-Garde Film", "Street Art",
        "Mural Painting", "Sculptural Installation", "Jewelry Design", "Sustainable Fashion", "Hydroponics", "Urban Farming",
        "Herpetology", "Ichthyology", "Spearfishing", "Archery", "Whitewater Kayaking", "Wakeboarding", "Free Diving",
        "BMX", "Rollerblading", "Geocaching", "Restoration", "Antique Restoration", "Clock Repair", "Watch Repair",
        "Bookbinding", "Lace Making", "Rug Making", "Chocolate Making", "Fermentation", "Tea Blending", "Wine Tasting",
        "Cocktail Making", "Brush Lettering", "Paper Quilling", "Illusion", "Mentalism", "Negotiation", "Mediation",
        "Civic Engagement", "Youth Development", "Online Learning", "Curriculum Development", "Historical Research",
        "Ancestry Research", "Smart Home Automation", "Open Source Software", "Regenerative Agriculture", "Ethical Consumption",
        "Raw Vegan", "Carnivore Diet", "Biohacking", "Transcendental Meditation", "Positive Psychology", "Growth Hacking",
        "Affiliate Marketing", "Email Marketing", "Copywriting", "A/B Testing", "Information Architecture", "Usability Testing",
        "Prototyping", "Kanban", "CI/CD", "Data Mining", "Predictive Analytics", "Recommender Systems", "Reinforcement Learning",
        "String Theory", "Relativity", "Epigenetics", "Developmental Psychology", "Game Theory", "Rhetorical Analysis",
        "Postmodern Literature", "Experimental Theatre", "Performance Art", "Street Photography Workshops", "Fashion Illustration",
        "Biophilic Design", "Rooftop Gardening", "Terrariums", "Paleontology", "Marine Biology", "Free Climbing", "Slacklining",
        "Kiteboarding", "Scuba Diving", "Base Jumping", "Downhill Skiing", "Street Workout", "Urban Exploration", "Salvage",
        "Vintage Collecting", "Porcelain Restoration", "Taxidermy", "Book Restoration", "Tatting", "Weaving", "Soap Making",
        "Cheese Making", "Coffee Roasting", "Bitters Making", "Flair Bartending", "Modern Calligraphy", "Paper Marbling",
        "Hypnosis", "Mental Arithmetic", "Conflict Resolution", "Diplomacy", "Policy Analysis", "Adult Education",
        "Educational Psychology", "Historical Preservation", "Land Surveying", "Home Automation", "Hardware Hacking",
        "Vertical Farming", "Conscious Consumption", "Fruitarian", "Locavore", "Nootropics", "Vipassana Meditation",
        "Emotional Intelligence", "Influencer Marketing", "Growth Marketing", "Conversion Rate Optimization", "Customer Journey Mapping",
        "Service Design", "Design Thinking", "Pair Programming", "Test-Driven Development", "Data Warehousing", "Business Intelligence",
        "Anomaly Detection", "Generative Adversarial Networks", "General Relativity", "Cosmic Microwave Background", "Synthetic Biology",
        "Social Psychology", "Behavioral Finance", "Discourse Analysis", "Literary Criticism", "Site-Specific Art", "Sound Design",
        "Fashion Styling", "Green Building", "Vertical Gardens", "Bonsai", "Paleobotany", "Ethology", "Deep Sea Diving",
        "Speed Climbing", "Highlining", "Foil Surfing", "Cave Diving", "Wingsuit Flying", "Cross-Country Skiing", "Calisthenics",
        "Buildering", "Urban Scavenging", "Upcycling", "Retro Gaming", "Model Train Collecting", "Anatomical Model Building",
        "Furniture Restoration", "Preserved Flowers", "Shibori Dyeing", "Basket Weaving", "Candle Making", "Sourdough Baking",
        "Tea Ceremony", "Molecular Gastronomy", "Aromatherapy", "Copperplate Calligraphy", "Book Arts", "Stage Illusions",
        "Memory Techniques", "Public Policy", "International Relations", "Special Education", "Instructional Design",
        "Digital Humanities", "Cartography", "Smart Grid Technology", "Reverse Engineering"]
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
//        if currentIndex >= words.count {
//            currentIndex = 0
//        }
//        
//        let newText = words[currentIndex]
//        
//        fetchChatSuggestions(userInput: newText, wordList: userInterestsAndHobbies)
//        
//        currentIndex += 1
        guard let userInput = searchTF.text, !userInput.isTFBlank else {
            AppFunctions.showSnackBar(str: "Add some interest")
            return
        }

        self.fetchChatSuggestions(userInput: userInput, wordList: self.userInterestsAndHobbies)

    }
    
    @IBOutlet weak var searchResultCV: UICollectionView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    
    private var currentIndex = 0
    private let words = ["texes","texas","prog", "med", "fin", "fina", "comp"]
    private var resultList = [String]()
    private var debounceWorkItem: DispatchWorkItem?

    // Keep track of selected cell indexPaths.
    var selectedIndexPaths: Set<IndexPath> = []
    
    let API_KEY_GPT = "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"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCV()
        searchTF.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultCV.collectionViewLayout.invalidateLayout()
    }
    
    func setupCV() {
        searchResultCV.dataSource = self
        searchResultCV.delegate = self
        searchResultCV.register(ResultCVCell.self, forCellWithReuseIdentifier: "ResultCVCell")
        
        /*if let layout = searchResultCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10 // Horizontal spacing between items
            layout.minimumLineSpacing = 10 // Vertical spacing between lines
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Spacing around the entire collection view
        }*/
        
        // Configure the flow layout for dynamic sizing.
        if let layout = searchResultCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            // Using automatic size so that each cell can size itself.
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.searchResultCV.addGestureRecognizer(tap2)
        self.searchResultCV.isUserInteractionEnabled = true
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: searchResultCV)
        guard let indexPath = searchResultCV.indexPathForItem(at: location) else { return }
        
        
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
        // Optional: Reload if needed for other cells
        searchResultCV.reloadItems(at: [indexPath])
    }
    

    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        debounceWorkItem?.cancel()  // Cancel any previous work item
        
        guard let userInput = textField.text, !userInput.isTFBlank else { return }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.fetchChatSuggestions(userInput: userInput, wordList: self!.userInterestsAndHobbies)
        }
        
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem) // Adjust delay (0.3s–0.5s recommended)
    }
    
    // MARK: - Fetching Suggestions Function
    
    func fetchChatSuggestions(userInput: String, wordList: [String]) {
        TimeTracker.shared.startTracking(for: "fetchChatSuggestions")
        
        let promptContent = """
You are provided with two inputs: a **user input (a short text fragment)** and a **predefined word list** containing up to 1000 words. Your task is to generate a **diverse yet relevant** list of **at least 20 autocomplete suggestions** that meets the following criteria:

### **1. List Matching (Direct & Related Terms)**
- Identify any words in the provided word list that **start with or are closely related to** the user input.
- **DO NOT include the user input itself (no "Islamabad (Direct Match)" or standalone input).**
- If an **exact match** is found in the list, **prioritize it** but avoid showing it alone—expand on it.
- If no exact match is found, suggest **closely related terms** (e.g., synonyms, variants, or associated concepts).  
- **Example:**
  - Input: `"NFL"` → List contains `"Football"`, so include `"Football"`.
  - Input: `"Islamabad"` → Instead of just `"Islamabad"`, include `"Islamabad Hotels"`, `"Islamabad Weather"`, `"Islamabad Airport"`.

### **2. Contextual & Domain-Specific Suggestions**
- If **fewer than 5 relevant matches exist**, expand by suggesting **highly relevant, field-specific words** across multiple domains:
  - **Finance & Business** (e.g., Finance, Financial Aid, FinTech, Finalization, Fiscal Policy)
  - **Technology & Computing** (e.g., Finite State Machine, Fingerprint Scanner, Firmware, Fiber Optics)
  - **Education & Research** (e.g., Final Exam, Findings, Fine Arts, Field Study)
  - **Science & Medicine** (e.g., Finasteride, Fin Whale, Fibrinogen, Filtration Process)
  - **Arts & Literature** (e.g., Figurative Language, Fiction Writing, Film Criticism, Folklore)
  - **Entertainment & Media** (e.g., Film Production, Fantasy Novels, Famous Personalities, Festival Events)
  - **History & Culture** (e.g., Feudal System, French Revolution, Federalism, Folktales)
  - **Sports & Recreation** (e.g., Fitness Training, Field Hockey, Freestyle Swimming, Football League)
  - **Psychology & Philosophy** (e.g., Freudian Theory, Free Will, Fundamental Attribution Error)
  - **Law & Government** (e.g., Federal Court, Felony Charges, Freedom of Speech)
  - **Geography & Environment** (e.g., Fjords, Fossil Fuels, Forest Conservation, Flood Management)
  - **City-Specific (if input is a location)** (e.g., Islamabad Hotels, Islamabad Weather, Islamabad Airport)

- **Avoid completely random words.** Every suggestion should either:
  - **Start with the input ("fina" → "Finance, Financial Aid, Final Exam")**
  - **Be a well-known, directly related term ("Islamabad" → "Islamabad Tourism, Islamabad Hotels")**  

### **3. Formatting & Output**
- Return **exactly 20 autocomplete suggestions** in a numbered list.
- **DO NOT include "Direct Match" text.**
- Prioritize exact & related matches from the predefined list first.
- Ensure results **span multiple fields for variety** without going off-topic.

### **Inputs:**
- **User Input:** "\(userInput)"
- **Word List:** "\(wordList.joined(separator: ", "))"

Provide the list **ONLY** in plain text format as:
1. Suggestion 1
2. Suggestion 2
3. Suggestion 3
...
"""
        
        let messages = [
            ChatMessage(role: "user", content: promptContent)
        ]
        
        let requestBody = ChatCompletionRequest(model: "gpt-3.5-turbo",
                                                messages: messages,
                                                max_tokens: 60,
                                                temperature: 0.5)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(API_KEY_GPT)",
            "Content-Type": "application/json"
        ]
        
        AF.request("https://api.openai.com/v1/chat/completions",
                   method: .post,
                   parameters: requestBody,
                   encoder: JSONParameterEncoder.default,
                   headers: headers)
        .validate()
        .responseDecodable(of: ChatCompletionResponse.self) { response in
            switch response.result {
                case .success(let chatResponse):
                    TimeTracker.shared.stopTracking(for: "fetchChatSuggestions")
                    if let suggestionsText = chatResponse.choices.first?.message.content {
                        Logs.show(message: "Searched Text: \(userInput)\nChat Suggestions: \(suggestionsText)")
                        let suggestions = suggestionsText
                            .split(separator: "\n")
                            .map { line in
                                // Remove numbering (e.g., "1. ", "2. ") and trim whitespace
                                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                                return trimmedLine.replacingOccurrences(
                                    of: "^\\d+\\.\\s*", // Regex pattern to match "1. ", "10. ", etc.
                                    with: "",
                                    options: .regularExpression
                                )
                            }
                        self.resultList.removeAll()
                        self.resultList = suggestions
                        self.searchResultCV.reloadData()
                    }
                case .failure(let error):
                    TimeTracker.shared.stopTracking(for: "fetchChatSuggestions")
                    Logs.show(message: "Error fetching chat suggestions: \(error)")
            }
        }
    }
    
}

extension SearchInterestVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCVCell",
                                                            for: indexPath) as? ResultCVCell else {
            return UICollectionViewCell()
        }
        
        let resultStr = resultList[indexPath.item]

        let isCellSelected = selectedIndexPaths.contains(indexPath)
        cell.configure(with: resultStr, selected: isCellSelected)
        return cell
    }
    

    
}

extension SearchInterestVC: UICollectionViewDelegateFlowLayout {
    
    // This method calculates the cell size based on its content.
    // It adds the intrinsic width of the text plus the image, spacing, and padding.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let title = resultList[indexPath.item]
        let font = UIFont.systemFont(ofSize: 17)
        let textAttributes = [NSAttributedString.Key.font: font]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        
        // Constants for the image, spacing, and padding.
        let imageWidth: CGFloat = 24      // assumed image width
        let spacing: CGFloat = 8          // spacing between image and label
        let horizontalPadding: CGFloat = 16 // left and right padding
        
        // Calculate the desired width.
        var cellWidth = textSize.width + imageWidth + spacing + horizontalPadding
        
        // Determine the maximum allowed width per cell (max 3 cells per row).
        // Adjust for inter-item spacing.
        let maxWidthPerCell = (collectionView.bounds.width - 2 * 8) / 3
        cellWidth = min(cellWidth, maxWidthPerCell)
        
        // Use a fixed or computed height (here a minimum height is set).
        let cellHeight: CGFloat = max(44, textSize.height + 16)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    
}
