//
//  Constants.swift
//  ImageFeed
//
//  Created by Adilkhan on 19/9/26.
//

nonisolated private enum Constants {
    static let accessKey = "Munqh1I8rEPkO4cP3-PpvhJPHvXTLPlJpypHV1dwcMI"
    static let secretKey = "bYTbYouOheDYwqMbMmozGRb9G_Gv8Auuauvvj6xkx-o"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
    
    static let keyAccessToken = "accessToken"
    static let authURLString = "https://unsplash.com/oauth/authorize"
}


nonisolated struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    let keyAccessToken: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String, keyAccessToken: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
        self.keyAccessToken = keyAccessToken
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.authURLString,
                                 defaultBaseURLString: Constants.defaultBaseURLString,
                                 keyAccessToken: Constants.keyAccessToken
        )
    }
}
