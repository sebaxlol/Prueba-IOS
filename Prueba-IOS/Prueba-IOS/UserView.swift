//
//  UserView.swift
//  Prueba-IOS
//
//  Created by Desarrollo TEAM on 6/04/23.
//
import SwiftUI

struct UserView: View {
    let id: Int
    let name: String
    let phone: String
    let email: String
    
    @State private var posts: [Post] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title)
            HStack {
                Image(systemName: "phone")
                Text(phone)
            }
            HStack {
                Image(systemName: "envelope")
                Text(email)
            }
            
            if posts.isEmpty {
                ProgressView()
            } else {
                List(posts, id: \.id) { post in
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchPosts()
        }
    }
    
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts?userId=\(id)") else {
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
                let posts = try decoder.decode([Post].self, from: data)
                
                DispatchQueue.main.async {
                    self.posts = posts
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
