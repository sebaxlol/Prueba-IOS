//
//  ContentView.swift
//  Prueba-IOS
//
//  Created by Desarrollo TEAM on 6/04/23.
//

import SwiftUI

struct User: Codable, Hashable {
    var id: Int
    var name: String
    var phone: String
    var email: String
}

struct Post: Codable, Hashable {
    var id: Int
    var userId: Int
    var title: String
    var body: String
}

struct ContentView: View {
    @State var searchText: String = ""
    @State var filteredUsers: [User] = []
    @State var allUsers: [User] = []
    @State var showEmptyListMessage = false
    
    internal let userDefaultsKey = "users"
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Buscar usuario")
                if showEmptyListMessage {
                    Text("List is empty")
                } else {
                    List(filteredUsers, id: \.self) { user in
                        NavigationLink(destination: UserView(id: user.id, name: user.name, phone: user.phone, email: user.email)) {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                HStack {
                                    Image(systemName: "phone")
                                    Text(user.phone)
                                }
                                HStack {
                                    Image(systemName: "envelope")
                                    Text(user.email)
                                }
                            }
                        }
                    }.navigationBarTitle("Usuarios")
                }
                
            }
            .onAppear {
                loadUsers()
            }
            .onChange(of: searchText) { searchText in
                filterUsers(searchText)
            }
        }
    }
    
    func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            filteredUsers = users
            allUsers = users
        } else {
            fetchUsers()
        }
    }
    
    func saveUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func fetchUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let users = try decoder.decode([User].self, from: data)
                
                DispatchQueue.main.async {
                    self.filteredUsers = users
                    self.allUsers = users
                    self.saveUsers(users)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func filterUsers(_ searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
            showEmptyListMessage = false
            return
        }
        
        let filtered = allUsers.filter { user in
            return user.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if filtered.isEmpty {
            showEmptyListMessage = true
        } else {
            showEmptyListMessage = false
        }
        
        filteredUsers = filtered
    }
}
