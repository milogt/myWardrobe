//
//  ClosetView.swift
//  Wearchive
//
//  Created by Guo Tian on 3/6/21.
//

import SwiftUI
import CoreData

struct ClosetView: View {
    
    @Environment(\.managedObjectContext) var moc
    // variable to listen to change in core data
    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    var fetchRequest: FetchRequest<Piece>
    var pieces: FetchedResults<Piece> {
        fetchRequest.wrappedValue
    }
    
    @State private var filterKeywords = " "
    @State private var newPieces = [Piece]()
    @State private var isEditing = false
    @State private var updated = false
    
    init() {
        //fetch all items from core data
        fetchRequest = FetchRequest(entity: Piece.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Piece.brand, ascending: true)])
        newPieces = filter(keywords: filterKeywords)
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                // search bar configuration
                HStack{
                    TextField("Enter keywords", text: $filterKeywords)
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                // display a button to clear text when editing
                                if isEditing {
                                    Button(action: {
                                        self.filterKeywords = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        // tap search bar to enable editing keywords
                        .onTapGesture {
                            isEditing = true
                            updated = false
                        }.onAppear {
                            newPieces = filter(keywords: "")
                        }
                        //when core data change, receive signal to reload data
                        .onReceive(didSave, perform: { _ in
                            newPieces = filter(keywords: filterKeywords)
                            print("Core Data changed.")
                            updated = true
                        })
                    //filter item list based on keywords entered
                    if isEditing {
                        Button(action: {
                            newPieces = filter(keywords: filterKeywords)
                            isEditing = false
                            filterKeywords = ""
                            print("Search results loaded.")
         
                        }) {
                            Text("Search")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                }
                // item list that each cell displays photo and information
                List {
                    ForEach(newPieces, id: \.self) { item in
                      NavigationLink( destination: ItemDetail(piece: item),
                       label: {
                        HStack {
                            if item.image != nil {
                                Image(uiImage: UIImage(data:item.image!)!)
                                .resizable().frame(width: 85, height: 85, alignment: .center).clipShape(Circle())
                                .aspectRatio(contentMode: .fill)
                            }
                            else {
                                Image("defaultPhoto")
                                .resizable().frame(width: 85, height: 85, alignment: .center).clipShape(Circle())
                            }
                            Text("\(item.brand!) \(item.name!)")
                        }
                      })
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("My Wardrobe").font(Font.system(size: 20, weight: .bold, design: .serif))
                        }.foregroundColor(Color("textAlt"))
                    }
                }
                // when core data changes, notify user within a period of time
                if updated {
                    Text("Items updated.")
                        .onAppear {DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                self.updated.toggle()
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())  //silent the error message when going to third or fourth                                                      child view, seems like a swiftui bug
        
    }
    
    // function to delete items from table view with core data updates
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { pieces[$0] }.forEach(moc.delete)
            do {
                try moc.save()
                print("Item deleted.")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        newPieces = filter(keywords: filterKeywords)
    }
    // filter the items in list with dynamic search result
    func filter(keywords:String) -> [Piece]{

        if keywords == "" {
            let new: [Piece] = pieces.filter { ($0.keywords?.contains(" ") ?? false) }
            return new
        }
        let new: [Piece] = pieces.filter { ($0.keywords?.range(of: filterKeywords, options: .caseInsensitive) != nil) }
        return new

    }
    
    
}

struct ClosetView_Previews: PreviewProvider {
    static var previews: some View {
        ClosetView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
