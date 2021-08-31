//
//  UpdateDetailView.swift
//  Wearchive
//
//  Created by Guo Tian on 3/9/21.
//

import SwiftUI
import CoreData

struct UpdateDetailView: View {
    @StateObject var piece:Piece
    @ObservedObject var List = TypeList()
    @Environment(\.managedObjectContext) private var moc
    @State private var updated = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var image:Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    
    @State private var item = Item(name: "", brand: "", color: "", type: "", subType:"",size: "", fabric: "", detail: "")
    
    var body: some View {
        VStack {
            Form {
                // handle item image with or without prefill photo
                ZStack{
                    Rectangle().fill(Color("colorSet"))
                        .aspectRatio(1.0, contentMode: .fit).background(Color("altBackground"))
                    if image != nil {
                        image?.resizable().aspectRatio(1.0, contentMode: .fit)
                    } else {
                        Text("Select photo").font(Font.system(size: 20, weight: .medium, design: .serif))
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                // handle user editing for each attributes
                TextField(piece.name!, text: $item.name)
                TextField(piece.brand!, text: $item.brand)
                Picker("Color & pattern", selection: $item.color) {
                    ForEach(List.lists[6].list, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Category", selection: $item.type) {
                    ForEach(List.lists[7].list, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Sub category", selection: $item.subType) {
                    ForEach(List.returnList(name:item.type), id: \.self) {
                        Text($0)
                    }
                }
                Picker("Size", selection: $item.size) {
                    ForEach(List.returnSize(typeName: item.type), id: \.self) {
                        Text($0)
                    }
                }
                Picker("Material", selection: $item.fabric) {
                    ForEach(List.lists[10].list, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Notes: \(piece.detail!)", text: $item.detail)
                // update button to modify the item in core data
                Button("Update") {
                    updateItem()
                    inputImage = nil
                    // automatically return to detailview
                    presentationMode.wrappedValue.dismiss()
                }.font(Font.system(size: 30, weight: .medium, design: .serif))
                
                .onAppear {
                    updated = true
                }
                // load item data to each editing field
                .onChange(of: updated, perform: { value in
                    if piece.image != nil {
                        inputImage = UIImage(data: piece.image!)
                        image = Image(uiImage: UIImage(data: piece.image!)!)
                    }
                    self.item.name = self.piece.name ?? ""
                    self.item.brand = self.piece.brand ?? ""
                    self.item.color = self.piece.color ?? ""
                    self.item.type = self.piece.type ?? ""
                    self.item.subType = self.piece.subType ?? ""
                    self.item.size = self.piece.size ?? ""
                    self.item.fabric = self.piece.fabric ?? ""
                    self.item.detail = self.piece.detail ?? ""
                })
            }
        // showing image picker view
        }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .background(Color("altBackground"))
    }
    
    // update the item in core data and save
    func updateItem() {
        moc.performAndWait {
            if inputImage != nil {
                piece.image = (inputImage?.jpegData(compressionQuality: 0.2))!
            }
            piece.name = item.name
            piece.brand = item.brand
            piece.color = item.color
            piece.type = item.type
            piece.subType = item.subType
            piece.size = item.size
            piece.fabric = item.fabric
            piece.detail = item.detail
            piece.keywords = item.config()
            try? moc.save()
        }
    }
    // load picked photo to image placeholder
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        showingImagePicker = false
        print("Photo selected.")
    }
}

struct UpdateDetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let item = Piece(context: moc)
        item.name = "hoodie"
        item.brand = "UChicago"
        item.color = "Red"
        item.size = "Large"
        item.type = "Tops"
        item.subType = "Sweats"
        item.fabric = "Cotton"
        item.detail = "Dresser by the door, second drawer"

        return NavigationView {
            UpdateDetailView(piece: item)
        }
    }
}


