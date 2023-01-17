//
//  ContentView.swift
//  Bruin Dining
//
//  Created by Marius Genton on 10/8/22.
//

import SwiftUI

struct Section: View {
    var title: String
    var text: String

    var body: some View {
        Text(title)
            .font(.system(.title2))
            .fontWeight(.bold)
            .padding([.top, .bottom])
        
        Text(text)
            .font(.system(.body))
            .padding(.bottom)
    }
}

struct ContentView: View {
    
    init() {
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(Color.accentColor)
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("This widget displays the dining halls and food trucks that are currently open along with their cosing time, or the time at which the next meal starts if none are open.")
                        .font(.system(.headline))
                        .padding(.bottom)

                    Section(
                        title: "Setup",
                        text: "1) From the Home Screen, touch and hold a widget or an empty area until the apps jiggle.\n\n2) Tap the Add button in the upper-left corner.\n\n3) Search for the BruinDining widget, choose a size, then tap Add Widget.\n\n4) Tap Done."
                    )
                    
                    Section(
                        title: "Customization",
                        text: "If you do not want the widget to include food trucks, you can hold the widget, tap \"Edit Widget\", and set \"Include food trucks\" to false."
                    )
                    

                    Spacer(minLength: 30)
                    Text("This app is not affiliated with UCLA or UCLA dining. For inquiries, contact me at mariusgenton@gmail.com")
                        .font(.system(.footnote))
                        .padding([.bottom, .top])
                        .multilineTextAlignment(.center)
                        .opacity(0.5)
                        .frame(maxWidth: .infinity)
                }
                .multilineTextAlignment(.leading)
                .padding()
            }
            .foregroundColor(.black)
            .background(Color.white)
            .preferredColorScheme(.dark)
            .navigationTitle("BruinDining")
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
