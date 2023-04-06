//
//  UserView.swift
//  Prueba-IOS
//
//  Created by Desarrollo TEAM on 6/04/23.
//

import Foundation
import SwiftUI

struct UserView: View {
    let id: Int
    @State var apiData: [ApiData]?

    var body: some View {
        VStack {
            if let data = apiData {
                List(data, id: \.id) { item in
                    VStack(alignment: .leading) {
                        Text(item.title)
                        Text(item.body)
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            loadData()
        }
    }

    func loadData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts?userId=\(id)") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([ApiData].self, from: data) {
                    DispatchQueue.main.async {
                        apiData = decodedResponse
                    }
                    return
                }
            }

            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ApiData: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
