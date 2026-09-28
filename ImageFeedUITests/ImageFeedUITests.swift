//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Adilkhan on 3/6/26.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        // Латинская раскладка: с русской клавиатурой typeText вводит в поле пароля только цифры
        app.launchArguments = ["-AppleKeyboards", "(\"en_US@sw=QWERTY;hw=Automatic\")"]
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        if !authButton.waitForExistence(timeout: 5) {
            // Приложение запустилось уже залогиненным — сначала выходим
            logout()
        }
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 15))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        tapUntilFocused(loginTextField)
        loginTextField.typeText("*")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        tapUntilFocused(passwordTextField)
        passwordTextField.typeText("*")
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        // Свайп по невысокой ячейке может засчитаться как тап и открыть фото, поэтому свайпаем всю таблицу
        tablesQuery.firstMatch.swipeUp()

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))

        // Фото может быть уже лайкнуто (например, после упавшего прогона), поэтому берём текущее состояние,
        // переключаем его и возвращаем обратно
        let likeButton = cellToLike.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'like button'")).firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 8))
        let initialIdentifier = likeButton.identifier
        let toggledIdentifier = initialIdentifier == "like button on" ? "like button off" : "like button on"

        cellToLike.buttons[initialIdentifier].tap()

        // Кнопка меняет идентификатор только после ответа сервера, поэтому ждём её, а не жмём сразу
        let toggledButton = cellToLike.buttons[toggledIdentifier]
        XCTAssertTrue(toggledButton.waitForExistence(timeout: 10))
        toggledButton.tap()

        XCTAssertTrue(cellToLike.buttons[initialIdentifier].waitForExistence(timeout: 10))

        cellToLike.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))
        navBackButtonWhiteButton.tap()

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testProfile() throws {
        let profileTabButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTabButton.waitForExistence(timeout: 10))
        profileTabButton.tap()

        XCTAssertTrue(app.staticTexts["*"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["@*"].exists)

        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let confirmButton = app.alerts["Пока, пока!"].buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()

        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }

    // WKWebView передаёт фокус полю асинхронно: без ожидания typeText падает с "Neither element nor any descendant has keyboard focus"
    private func tapUntilFocused(_ element: XCUIElement) {
        let hasFocus = NSPredicate(format: "hasKeyboardFocus == true")
        for _ in 0..<3 {
            element.tap()
            let focusExpectation = XCTNSPredicateExpectation(predicate: hasFocus, object: element)
            if XCTWaiter.wait(for: [focusExpectation], timeout: 2) == .completed {
                return
            }
        }
        XCTFail("Поле не получило фокус клавиатуры")
    }

    private func logout() {
        let profileTabButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTabButton.waitForExistence(timeout: 10))
        profileTabButton.tap()

        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let confirmButton = app.alerts["Пока, пока!"].buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()
    }
}
