//
//  SplashView.swift
//  Wearchive
//
//  Created by Guo Tian on 3/10/21.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        //load splash screen from image sets 
        Image("splash").resizable()
        .edgesIgnoringSafeArea(.all).aspectRatio(contentMode: .fill)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
