//
//  ItemDetail.swift
//  Wearchive
//
//  Created by Guo Tian on 3/7/21.
//

import SwiftUI
import CoreData

struct ItemDetail: View {
    @ObservedObject var piece: Piece
//    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(entity: Piece.entity(), sortDescriptors: []) var pieces: FetchedResults<Piece>
    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    @State private var updated = false
    
    
    var body: some View {
        ScrollView {
            VStack {
            // use geometryreader to create sticky header image
            GeometryReader { gr in
                if piece.image != nil {
                    Image(uiImage: UIImage(data:piece.image!)!)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(width:gr.size.width,height:self.calculateHeight(minHeight: 200,maxHeight: 400,yOffset: gr.frame(in:.global).origin.y))
                        .offset(y: gr.frame(in: .global).origin.y < 0
                            ? abs(gr.frame(in: .global).origin.y)
                            : -gr.frame(in: .global).origin.y)
                }
                // provide a default photo if user hasn't chosen a photo
                else {
                    Image("defaultPhoto")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 230)
                }
            }
            .onDisappear{
                updated = false
            }
            // display item details
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                HStack{
                    Text(piece.brand!).font(Font.system( size: 30, weight: .bold, design: .serif))
                    Text(piece.name!).font(.title)
                }
                Text("Color: \(piece.color!)")
                Text("Size: \(piece.size!)")
                Text("Category: \(piece.type!), \(piece.subType!)")
                Text("Notes: \(piece.detail!)")
            }
            .font(Font.system(size: 20, weight: .medium, design: .serif))
            .padding(.horizontal, 15)
            .padding(.top, retHeight())
            .frame(width: UIScreen.main.bounds.size.width,alignment: .leading)
            }
            .onReceive(didSave, perform: { _ in
                updated = true
            })
        }//.edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Text(piece.name!)
                        .foregroundColor(Color("textAlt"))
                        .font(Font.system(size: 20, weight: .bold, design: .serif))
            }
            // bar item button to instantiate editing view
            ToolbarItem(placement: .primaryAction){
                if !updated {       // to handle a weird swiftui behavior that everytime parent view updated, it
                                    // automatically re-enter child view. I temporarily disable the edit once updated
                NavigationLink( destination: UpdateDetailView(piece: piece),
                 label: {
                    Text("Edit")
                 })
                }
            }
        }
        
    }
    
    // calculate the height when scrolling to create sticky header effect
    func calculateHeight(minHeight: CGFloat, maxHeight: CGFloat, yOffset: CGFloat) -> CGFloat {
        if maxHeight + yOffset < minHeight {
            return minHeight
        }
        else if maxHeight + yOffset > maxHeight {
            return maxHeight + (yOffset * 0.5)
        }
        return maxHeight + yOffset
    }
    
    // calculate detail info height when dealing with different size image
    func retHeight() -> CGFloat {
        if piece.image != nil {
            let height = UIImage(data:piece.image!)!.size.height
            let width = UIImage(data:piece.image!)!.size.width
            if height > width {
                return height/width * 260
            }
            else{
                return 320
            }
        }
        else {
            return 280
        }
    }
}


struct ItemDetail_Previews: PreviewProvider {
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
            ItemDetail(piece: item)
        }
    }
}


