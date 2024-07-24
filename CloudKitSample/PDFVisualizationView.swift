//
//  PDFVisualizationView.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 22/07/24.
//

import Foundation
import UIKit
import PDFKit


class PDFVisualizationView: UIViewController, UIDocumentPickerDelegate {
	
	let cc = CloudController()
	var currentDocument: Document? = nil
	
	let pdfView: PDFView = {
		let view = PDFView(frame: .zero)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.autoScales = true
		
		return view
	}()
	
	let getPDFButton: UIButton = {
		let button = UIButton()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Get PDF", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .white
		
		return button
	}()
	
	let downloadPDFButton: UIButton = {
		let button = UIButton()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Download PDF", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.backgroundColor = .cyan
		
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
	}
	
	func setupUI() {
		setupGetPDFButton()
		setupDownloadButton()
		setupPDFView()
	}
	
	func setupGetPDFButton() {
		self.view.addSubview(getPDFButton)
		
		getPDFButton.addTarget(self, action: #selector(getPDF), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			getPDFButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			getPDFButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
		])
	}
	
	@objc func getPDF() {
		Task {
			let documents = cc.getAllDocuments
			self.currentDocument = await documents().first
			let url = await documents().first?.data?.fileURL!
			let pdfDocument = PDFDocument(url: url!)
			self.pdfView.document = pdfDocument
		}
	}
	
	func setupDownloadButton() {
		self.view.addSubview(downloadPDFButton)
		
		downloadPDFButton.addTarget(self, action: #selector(didDownloadPDF), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			downloadPDFButton.topAnchor.constraint(equalTo: getPDFButton.bottomAnchor),
			downloadPDFButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
		])
	}
	
	@objc func didDownloadPDF() {
//		ShareLink em SwiftUI
		if let pdfURL = self.pdfView.document?.documentURL {
			DispatchQueue.main.async {
				let pdfData = try? Data.init(contentsOf: pdfURL)
				let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
				let pdfNameFromURL = "Document-\(self.currentDocument?.title ?? "YourDocument").pdf"
				let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromURL)
				do {
					let fileManager = FileManager.default
					
					try pdfData?.write(to: actualPath, options: [.atomic])
					
					// MARK: abre o aplicativo Files
//					let path = self.getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
//					let documentURL = URL(string: path)!
//					
//					UIApplication.shared.open(documentURL)
					
					let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
					let docURL = NSURL(fileURLWithPath: docPath)
					
					if let pathComponent = docURL.appendingPathComponent("Document-\(self.currentDocument?.title ?? "YourDocument").pdf") {
						let filePath = pathComponent.path
						print("filePath: \(filePath)")
						
						if fileManager.fileExists(atPath: filePath) {
							print("FILE AVAILABLE")
							print("PDF successfully saved!")
						} else {
							print("FILE NOT AVAILABLE")
						}
					} else {
						print("FILE PATH NOT AVAILABLE")
					}
				} catch {
					print("PDF could not be saved :(")
				}
			}
		}
		else {
			print("PDF could not be found!")
		}
	}
	
	func setupPDFView() {
		self.view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: downloadPDFButton.bottomAnchor),
			pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
}

extension PDFVisualizationView {
	func getDocumentsDirectory() -> URL {  // returns your application folder
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
