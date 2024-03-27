//
//  ContentView.swift
//  fitend Watch App
//
//  Created by Shimmy on 3/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var session = WatchSessionDelegate();
    @State private var message = "";
    
    var body: some View {
        ScrollView {
            //textField
            TextField("Enter Your Message", text: $message).padding()
            HStack{
                //button
                Button("send", action: {
                    session.sendMessage([message: String()])
                })
                //refresh
                Button("refresh", action: {
                    session.refresh()
                    }
                )
            }
            //log
            Text("Log")
            ForEach(session.log, id:\.self){
                Text($0)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
