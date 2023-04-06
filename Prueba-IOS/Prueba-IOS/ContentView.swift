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

struct ContentView: View {
    @State private var filter: String = ""
    @State private var users: [User] = []
    @State private var filteredUsers: [User] = []
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $filter, placeholder: "Buscar usuario")
                if filteredUsers.isEmpty {
                                Text("List is empty")
                            } else {
                                List(filteredUsers, id: \.self) { user in
                                    NavigationLink(destination: UserView(id: user.id)) {
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
                            fetchUsers()
            }
        
            .onChange(of: filter) { newValue in
                if newValue.isEmpty {
                    filteredUsers = users
                } else {
                    filteredUsers = users.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                }
            }
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
                    self.users = users
                    self.filteredUsers = users
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
