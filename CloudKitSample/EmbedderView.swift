//
//  EmbedderView.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import UIKit
import SwiftUI

struct EmbedderView: UIViewControllerRepresentable {
	
	typealias UIViewControllerType = PDFUIKITVIEW
	
	func makeUIViewController(context: Context) -> PDFUIKITVIEW {
		PDFUIKITVIEW()
	}
	
	func updateUIViewController(_ uiViewController: PDFUIKITVIEW, context: Context) {
		//
	}
}
