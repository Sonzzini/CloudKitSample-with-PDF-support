//
//  PDFUIKITVIEW.swift
//  CloudKitSample
//
//  Created by Paulo Sonzzini Ribeiro de Souza on 18/07/24.
//

import Foundation
import UIKit
import PDFKit
import CloudKit

class PDFUIKITVIEW: UIViewController, UIDocumentPickerDelegate {
	
	var doc: Document? = nil
	var urls: [URL]? = nil
	
	let documentButton: UIButton = {
		let button = UIButton()
		
		button.setTitle("Open", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .blue
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()
	
	let saveDocumentButton: UIButton = {
		let button = UIButton()
		
		button.setTitle("Save", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .black
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
	
	let goFetchPDFViewButton: UIButton = {
		let button = UIButton()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Go Fetch", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .black
		
		return button
	}()
	
	let pdfView: PDFView = {
		let view = PDFView(frame: .zero)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.autoScales = true
		
		return view
	}()
	
	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		
		return view
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		
	}
	
	func setupUI() {
		setDocButton()
		setFindButton()
		setSaveButton()
//		setImageView()
		setNextViewButton()
		setPdfView()
	}
	
	func setDocButton() {
		self.view.addSubview(documentButton)
		
		documentButton.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			documentButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			documentButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
			documentButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
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
		let searchKeyword = "DomAIn" // The search engine is also case insensitive with the search word :thumbsup:
		
		let searchOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
		guard let document = pdfView.document else { return }
		print(document)
		let results = document.findString(searchKeyword, withOptions: searchOptions)
		for result in results {
			print(result.pages)
			pdfView.go(to: result.pages[0])
		}
		
	}
	
	func setSaveButton() {
		self.view.addSubview(saveDocumentButton)
		
		saveDocumentButton.addTarget(self, action: #selector(saveDoc), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			saveDocumentButton.topAnchor.constraint(equalTo: tryToFindButton.bottomAnchor),
			saveDocumentButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			saveDocumentButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
		])
	}
	@objc func saveDoc() {
		
		let alert = UIAlertController(title: "Enviar PDF", message: "Dê um nome ao arquivo", preferredStyle: .alert)
		alert.addTextField()
		
		let submitAction = UIAlertAction(title: "Enviar", style: .default) { [unowned alert] _ in
			let answer = alert.textFields![0]
			if let doc = self.doc {
					Task {
						var cc: CloudController? = CloudController()
						doc.title = answer.text ?? ""
						await cc?.saveDocument(document: doc)
						cc = nil
					}
			}
		}
		let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
		
		alert.addAction(submitAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}
	
	func setImageView() {
		self.view.addSubview(imageView)
		
		imageView.image = nil
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: saveDocumentButton.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			imageView.widthAnchor.constraint(equalToConstant: 200)
		])
	}
	
	func setNextViewButton() {
		self.view.addSubview(goFetchPDFViewButton)
		
		goFetchPDFViewButton.addTarget(self, action: #selector(presentFetchView), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			goFetchPDFViewButton.topAnchor.constraint(equalTo: saveDocumentButton.bottomAnchor),
			goFetchPDFViewButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			goFetchPDFViewButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
		])
	}
	
	@objc func presentFetchView() {
		let vc = PDFVisualizationView()
//		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}
	
	func setPdfView() {
		self.view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: goFetchPDFViewButton.bottomAnchor),
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
		
		guard 
			let document = PDFDocument(url: url)
		else { return }
		
		pdfView.document = document
		
		let pdfAsset = CKAsset(fileURL: url)
		
		let metadata = document.documentAttributes!
		
		_ = document.dataRepresentation()
//		let convertedData = cc.convert64EncodedToHex(data!)
//		
//		let key = CloudController.shared.key
//		let encryptedData = cc.encrypt(data: data!, using: key)
//		
//		let decryptedData = cc.decrypt(data: encryptedData!, using: key)
		
//		print(data)
//		print(encryptedData)
//		print(decryptedData)
//		print(data?.base64EncodedString())
		
		_ = url.path()
		
		if let pdfTitle = metadata[PDFDocumentAttribute.titleAttribute] as? String {
			self.doc = Document(asset: pdfAsset, title: pdfTitle)
//			self.doc = Document(imagePath: filePath, title: pdfTitle, data: data) // MARK: Dados encriptados não estão sendo enviados
		} else {
			self.doc = Document(asset: pdfAsset, title: "DocumentTitle")
//			self.doc = Document(imagePath: filePath, title: "DocumentTitle", data: data)
		}
		
		
	}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		dismiss(animated: true)
	}
}
