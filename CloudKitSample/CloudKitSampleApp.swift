//
//  CloudKitSampleApp.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 17/07/24.
//

import SwiftUI

@main
struct CloudKitSampleApp: App {
	
	let CC = CloudController()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(CC)
		}
	}
}
