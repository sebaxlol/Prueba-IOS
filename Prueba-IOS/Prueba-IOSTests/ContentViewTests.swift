//
//  ContentViewTests.swift
//  Prueba-IOSTests
//
//  Created by Desarrollo TEAM on 6/04/23.
//

@testable import Prueba_IOS
import XCTest

class ContentViewTests: XCTestCase {
    
    var sut: ContentView!
    
    override func setUp() {
        super.setUp()
        sut = ContentView()
        sut.allUsers = [
            User(id: 1, name: "John Doe", phone: "555-555-1234", email: "johndoe@gmail.com"),
            User(id: 2, name: "Jane Smith", phone: "555-555-5678", email: "janesmith@gmail.com"),
            User(id: 3, name: "Bob Johnson", phone: "555-555-9876", email: "bobjohnson@gmail.com")
        ]
        sut.filteredUsers = sut.allUsers
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLoadUsersFromUserDefaults() {
        // Given
        let users = [
            User(id: 4, name: "Amy Brown", phone: "555-555-1111", email: "amybrown@gmail.com")
        ]
        let data = try? JSONEncoder().encode(users)
        UserDefaults.standard.set(data, forKey: sut.userDefaultsKey)
        
        // When
        sut.loadUsers()
        
        // Then
        XCTAssertEqual(sut.filteredUsers.count, 1)
        XCTAssertEqual(sut.filteredUsers[0].name, "Amy Brown")
    }
    
    func testLoadUsersFromAPI() {
        // Given
        let expectation = self.expectation(description: "Fetch users from API")
        
        // When
        sut.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(sut.filteredUsers.count > 0)
    }
    
    func testFilterUsers() {
        // Given
        let searchText = "John"
        
        // When
        sut.filterUsers(searchText)
        
        // Then
        XCTAssertEqual(sut.filteredUsers.count, 1)
        XCTAssertFalse(sut.filteredUsers.isEmpty)
        XCTAssertEqual(sut.filteredUsers[0].name, "John Doe")
    }
    
    func testEmptySearchTextShowsAllUsers() {
        // Given
        sut.filterUsers("John")
        XCTAssertEqual(sut.filteredUsers.count, 1)
        
        // When
        sut.filterUsers("")
        
        // Then
        XCTAssertEqual(sut.filteredUsers.count, sut.allUsers.count)
    }
    
    func testEmptyListMessageIsShownWhenNoResultsFound() {
        // Given
        sut.filterUsers("Invalid User")
        
        // Then
        XCTAssertTrue(sut.showEmptyListMessage)
    }
    
    func testEmptyListMessageIsNotShownWhenResultsFound() {
        // Given
        sut.filterUsers("John")
        
        // Then
        XCTAssertFalse(sut.showEmptyListMessage)
    }
}
