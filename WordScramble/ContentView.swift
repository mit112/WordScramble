//
//  ContentView.swift
//  WordScramble
//
//  Created by Mit Sheth on 1/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: {
                startGame()
            })
            .alert(errorTitle, isPresented: $showingError) { }
        message: {
            Text(errorMessage)
        }
        .toolbar  {
            ToolbarItem() {
                Button("Restart Game"){
                    restartGame()
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Text("Score: \(score)")
            }
            ToolbarItem(placement: .bottomBar) {
                Button("New Word") {
                    startGame()
                }
            }
        }
            
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard answer.count > 2 else {
            wordError(title: "Word too short", message: "Word can't be shorter than 3 letters")
            return
        }
        
        
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible.", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already!", message: "Try again.")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "That's not a real word, lol.", message: "You can't just make them up boo")
            return
        }
        _=calculateScore(word: answer)

        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScore(word: String) -> Int {
        let count = word.count
        score += count
        return score
    }
    func restartGame() {
        startGame()
        score = 0
    }
    
}

#Preview {
    ContentView()
}
