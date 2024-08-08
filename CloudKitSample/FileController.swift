//
//  FileController.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 08/08/24.
//

import Foundation
import UIKit

class FileController {
	
	init() {
		
	}
	
	deinit {
		let byePhrases = ["Goodbye!", "See you next time!", "Until soon!", "See you later, alligator!"]
		print("FileController says: \(byePhrases.randomElement()!)")
	}
	
	func downloadPDF(pdfURL: URL, document: Document) {
		let fileManager = FileManager.default
		
		DispatchQueue.main.async {
			let pdfData = try? Data.init(contentsOf: pdfURL)
			let resourceDocPath = (fileManager.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
			
			var pdfNameFromURL = "Document-\(document.title)"
			var actualPath = resourceDocPath.appendingPathComponent(pdfNameFromURL+".pdf")
			var num = 1
			
			while fileManager.fileExists(atPath: actualPath.path()) {
				
				if pdfNameFromURL.hasSuffix(")") {
					pdfNameFromURL.removeLast()
					pdfNameFromURL.removeLast()
					pdfNameFromURL.removeLast()
					pdfNameFromURL.append("(\(num))")
				} else {
					pdfNameFromURL.append("(\(num))")
				}
				
				actualPath = resourceDocPath.appendingPathComponent(pdfNameFromURL+".pdf")
				
				num += 1
			}
			
			do {
				try pdfData?.write(to: actualPath, options: [.atomic])
				
				// MARK: abre o aplicativo Files
				let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
				let documentURL = URL(string: path)!
				UIApplication.shared.open(documentURL)
				
				let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
				
				let docURL = NSURL(fileURLWithPath: docPath)
				
				if let pathComponent = docURL.appendingPathComponent("Document-\(document.title).pdf") {
					let filePath = pathComponent.path
					
					if fileManager.fileExists(atPath: filePath) {
						print("File Available")
						print("PDF successfully saved!")
						
						// ALERT
					} else {
						print("File not available")
					}
				} else {
					print("File path not available")
				}
			} catch {
				print("PDF could not be saved")
			}
		}
	}
	
	
	func getDocumentsDirectory() -> URL {  // Devolve a sua pasta de documents da aplicação
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
