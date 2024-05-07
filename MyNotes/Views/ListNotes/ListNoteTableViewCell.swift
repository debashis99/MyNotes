//
//  ListNoteTableViewCell.swift
//  MyNotes
//
//  Created by Employee on 06/05/24.
//

import UIKit

class ListNoteTableViewCell: UITableViewCell {

    static let identifier = "ListNoteTableViewCell"
    
    @IBOutlet weak private var titleLbl: UILabel!
    @IBOutlet weak private var descriptionLbl: UILabel!
    
    func setup(note: Note) {
        let encryptedText = note.title
        var decryptedText: String = ""
        do {
            decryptedText = try CoreDataManager.shared.decrypt(encryptedText )
        } catch {
            decryptedText = note.title
        }
        titleLbl.text = decryptedText
        descriptionLbl.text = note.desc 
    }
}
