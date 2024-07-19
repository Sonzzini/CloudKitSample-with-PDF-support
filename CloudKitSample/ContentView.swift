//
//  ContentView.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 17/07/24.
//

import SwiftUI

struct ContentView: View {
	
	@EnvironmentObject var cc: CloudController
	
	@State var lamps: [Lamp] = []
	
	var body: some View {
		NavigationStack {
			VStack {
				
				NavigationLink {
					PDFViewXD()
				} label: {
					Text("Go to PDFView")
				}
				.buttonStyle(BorderedProminentButtonStyle())

				
				HStack {
					Button {
						let lamp = Lamp(name: "Nome", price: 99.99, size: 10)
						lamps.append(lamp)
						Task {
							await cc.saveLamp(lamp: lamp)
						}
					} label: {
						Text("Create Lamp")
					}
					
					Button {
						cc.saveEmily()
					} label: {
						Text("Salvar Emily")
					}
				}
				
				Button("Get Lamps") {
					Task {
						lamps = await cc.getAllLamps()
					}
				}
				
				if !lamps.isEmpty {
					List(lamps) { lamp in
						Text("\(lamp.name)")
							.swipeActions {
								Button("Delete", role: .destructive) {
									Task {
										await cc.deleteLamp(lamp: lamp)
									}
								}
							}
					}
				}
				
			}
		}
	}
}


#Preview {
	ContentView()
}
