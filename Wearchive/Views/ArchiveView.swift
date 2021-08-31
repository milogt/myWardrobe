//
//  ArchiveView.swift
//  Wearchive
//
//  Created by Guo Tian on 3/6/21.
//

import SwiftUI
import CoreData

struct ArchiveView: View {
    // string data of different attributes for picker views
    @ObservedObject var List = TypeList()
    @State private var showingAlert = false
    @State private var showInstruction = false
    @State private var image:Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var item = Item(name: "", brand: "", color: "", type: "", subType:"",size: "", fabric: "", detail: "")
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Piece.entity(), sortDescriptors: []) var pieces: FetchedResults<Piece>
    
    var body: some View {
      NavigationView {
        VStack(alignment:.leading,spacing:0){
            HStack{
                //photo selection field, display the photo when user picks one
                ZStack{
                    Rectangle().fill(Color("colorSet"))
                        .aspectRatio(1.0, contentMode: .fit)
                    if image != nil {
                        image?.resizable().aspectRatio(1.0, contentMode: .fit)
                    } else {
                        Text("Select photo").font(Font.system(size: 20, weight: .medium, design: .serif))
                    }
                }
                .padding([.top,.leading,.bottom],18)
                .onTapGesture {
                    self.showingImagePicker = true
                }
                VStack{
                  // textfield sections to handle user input with styling
                  Section {
                    TextField("Item name", text: $item.name).textFieldStyle(RoundedBorderTextFieldStyle()).font(Font.system(size: 20, weight: .medium, design: .serif))
                    TextField("Brand", text: $item.brand).font(Font.system(size: 20, weight: .medium, design: .serif)).textFieldStyle(RoundedBorderTextFieldStyle())
                  }.padding([.trailing,.bottom,.top],10)
                }
            }
            .background(Color("altBackground"))
            .onTapGesture {
                endEditing()
            }
            
            // pickers to simplify the process of creating new items
            Form {
              Section {
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
                Picker("Sub Category", selection: $item.subType) {
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
                TextField("Notes (where I put, retail price...)", text: $item.detail)
              }
              .padding(12)
              .font(Font.system(size: 15, weight: .medium, design: .serif))
            }

            HStack{
                // button to insert item into core data
                Button(action: {
                    addItem()
                    reinitialize()
                    showingAlert = true
                    print("Total items in wardrobe:\(pieces.count)")
                    }) {
                    HStack {
                        Image(systemName: "plus.diamond")
                            .font(.title)
                        Text("archive   ")
                            .font(Font.system(size: 24, weight: .bold, design: .serif))
                    }
                    .padding(10)
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Congratulation!"), message: Text("New item hang in your wardrobe now."), dismissButton: .default(Text("OK")))
                }
                Spacer()
                // button to clear all the textfields and picker selection
                Button(action: {
                    reinitialize()
                    print("Input discarded.")
                    }) {
                    HStack {
                        Image(systemName: "trash.circle")
                            .font(.title)
                        Text("discard   ")
                            .font(Font.system(size: 24, weight: .bold, design: .serif))
                    }
                    .padding(10)
                    .foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                }
            }
            .padding([.leading,.trailing,.bottom],15)
            .background(Color("altBackground"))
        }
        // instantiate image picker view
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Wearchive").font(Font.system(size: 20, weight: .bold, design: .serif))
                }.foregroundColor(Color("textAlt"))
            }
            // bar item button to display user instruction
            ToolbarItem(placement: .primaryAction){
                Button ( action: {
                    showInstruction = true
                }) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
      }
      .alert(isPresented: $showInstruction) {
          Alert(title: Text("User Instruction"), message: Text("Archive your clothes into wardrobe. Browse your items using search. View item details and edit when needed."), dismissButton: .default(Text("Got it!")))
      }
    }
    
    // insert new item instance into core data
    func addItem() {
        withAnimation {
            let newItem = Piece(context: moc)
            newItem.id = UUID()
            newItem.name = item.name
            newItem.brand = item.brand
            newItem.color = item.color
            newItem.type = item.type
            newItem.subType = item.subType
            newItem.size = item.size
            newItem.fabric = item.fabric
            newItem.detail = item.detail
            newItem.keywords = item.config()
            if inputImage != nil {
                newItem.image = (inputImage?.jpegData(compressionQuality: 0.1))!
            }

            do {
                try moc.save()
                print("New item added.")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // load images when user select photos from library
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        showingImagePicker = false
        print("Photo selected")
    }
    
    // clean the textfield and picker selection for quick discard
    func reinitialize() {
        item = Item(name: "", brand: "", color: "", type: "", subType:"",size: "", fabric: "", detail: "")
        image = nil
        inputImage = nil
    }
    // responds to tapping outside to dismiss the keyboard
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
