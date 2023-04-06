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
    @State private var searchText: String = ""
    @State private var filteredUsers: [User] = []
    @State private var allUsers: [User] = []
    @State private var showEmptyListMessage = false
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Buscar usuario")
                if showEmptyListMessage {
                    Text("La lista está vacía")
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
                fetchUsers()
            }
            .onChange(of: searchText) { _ in
                filterUsers()
            }
        }
    }
    
    func fetchUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            print("URL inválida")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No se ha recibido información de la API")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let users = try decoder.decode([User].self, from: data)
                
                DispatchQueue.main.async {
                    self.allUsers = users
                    self.filteredUsers = users
                }
            } catch {
                print("Error al decodificar el JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    private func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = allUsers
            showEmptyListMessage = false
            return
        }
        
        filteredUsers = allUsers.filter { user in
            return user.name.localizedCaseInsensitiveContains(searchText)
        }
        
        showEmptyListMessage = filteredUsers.isEmpty
    }
}
