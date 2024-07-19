//
//  PDFView.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFViewXD: View {
	
	@EnvironmentObject var cc: CloudController
	
	var body: some View {
		NavigationStack {
			
			EmbedderView()
			
		}
	}
}

#Preview {
	PDFViewXD()
}
