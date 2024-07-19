//
//  PDFUIKITVIEW.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import UIKit
import PDFKit

class PDFUIKITVIEW: UIViewController, UIDocumentPickerDelegate {
	
	let documentButton: UIButton = {
		let button = UIButton()
		
		button.setTitle("Open", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .blue
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()
	
	let tryToFindButton: UIButton = {
		let button = UIButton()
		
		button.setTitle("Find", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .green
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()
	
	let pdfView: PDFView = {
		let view = PDFView(frame: .zero)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.autoScales = true
		
		return view
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		
	}
	
	func setupUI() {
		setDocButton()
		setFindButton()
		setPdfView()
	}
	
	func setDocButton() {
		self.view.addSubview(documentButton)
		
		documentButton.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			documentButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			documentButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
			documentButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
		])
	}
	@objc func openDocumentPicker() {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .png])
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = .overFullScreen
		
		present(documentPicker, animated: true)
	}
	
	func setFindButton() {
		self.view.addSubview(tryToFindButton)
		
		tryToFindButton.addTarget(self, action: #selector(tryToFind), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			tryToFindButton.topAnchor.constraint(equalTo: documentButton.bottomAnchor),
			tryToFindButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			tryToFindButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
		])
	}
	@objc func tryToFind() {
		let searchKeyword = "domain"
		
		let searchOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
		guard let document = pdfView.document else { return }
		let results = document.findString(searchKeyword, withOptions: searchOptions)
		for result in results {
			print(result.pages)
			pdfView.go(to: result.pages[0])
		}
		
	}
	
	func setPdfView() {
		self.view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: tryToFindButton.bottomAnchor),
			pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

extension PDFUIKITVIEW {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		dismiss(animated: true)
		
		guard url.startAccessingSecurityScopedResource() else { return }
		
		defer {
			url.stopAccessingSecurityScopedResource()
		}
		
		guard let document = PDFDocument(url: url) else { return }
		pdfView.document = document
	}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		dismiss(animated: true)
	}
}
