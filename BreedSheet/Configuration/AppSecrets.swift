//
//  AppSecrets.swift
//  BreedSheet
//
//  Created by Pim on 30/07/2026.
//

import Foundation

/// Loads build-time configuration from the Info.plist entries populated by `Configuration/Secrets.xcconfig`
enum AppSecrets {
	enum ConfigurationError: Error, LocalizedError, Equatable {
		case missingInfoPlistKey(String)
		case invalidBaseURL(String)

		var errorDescription: String? {
			switch self {
			case .missingInfoPlistKey(let key):
				"Missing required Info.plist key '\(key)'. Copy Configuration/Secrets.template.xcconfig to " +
				"Configuration/Secrets.xcconfig and fill in your own values before building."
			case .invalidBaseURL(let value):
				"CAT_API_BASE_URL value '\(value)' is not a valid URL. Check Configuration/Secrets.xcconfig."
			}
		}
	}

	static func catAPIKey() throws(ConfigurationError) -> String {
		try infoPlistString(forKey: "CatAPIKey")
	}

	static func catAPIBaseURL() throws(ConfigurationError) -> URL {
		let value = try infoPlistString(forKey: "CatAPIBaseURL")
		guard let url = URL(string: value) else {
			throw .invalidBaseURL(value)
		}
		return url
	}

	private static func infoPlistString(forKey key: String) throws(ConfigurationError) -> String {
		guard
			let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
			value.isEmpty == false
		else {
			throw .missingInfoPlistKey(key)
		}
		return value
	}
}
