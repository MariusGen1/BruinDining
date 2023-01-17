//
//  BruinDining_Widget.swift
//  BruinDining_Widget
//
//  Created by Marius Genton on 1/14/23.
//

import WidgetKit
import SwiftUI
import Intents


let SampleEntryData = [
    OpenRestaurant(name: "Epicuria", closingTime: "15:00"),
    OpenRestaurant(name: "Feast", closingTime: "15:00"),
    OpenRestaurant(name: "The Study", closingTime: "15:30"),
    OpenRestaurant(name: "Bruin Plate", closingTime: "15:30"),
    OpenRestaurant(name: "De Neve", closingTime: "16:00"),
    //OpenRestaurant(name: "Rieber Food Trucks", closingTime: "16:00"),
    //OpenRestaurant(name: "Sproul Food Trucks", closingTime: "16:00"),
    //OpenRestaurant(name: "Epic at Ackerman", closingTime: "16:30"),
    //OpenRestaurant(name: "The Drey", closingTime: "16:30")
]

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: SampleEntryData, configuration: ConfigurationIntent(), nextMealOpening: "")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Task {
            let dataManager = DataManager()
            let diningHours = await dataManager.fetchDiningHours()
            
            var entries = [SimpleEntry]()
            
            var entryTimes = diningHours.timelineUpdateDates().filter { date in date >= Date() }
            entryTimes.append(Date())
            entryTimes.sort()
            
            for entryTime in entryTimes {
                let entryData = diningHours.open(entryTime)
                print(entryTime, entryData, diningHours.nextMeal(entryTime), "\n")
                entries.append(SimpleEntry(
                    date: entryTime,
                    data: entryData,
                    //data: SampleEntryData,
                    configuration: configuration,
                    nextMealOpening: diningHours.nextMeal(entryTime))
                )
            }
            
            let timeline = Timeline(entries: entries, policy: .after(diningHours.nextTimelineDate()))
            completion(timeline)
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: [OpenRestaurant]
    let configuration: ConfigurationIntent
    let nextMealOpening: String
    
    init(date: Date, data: [OpenRestaurant], configuration: ConfigurationIntent, nextMealOpening: String) {
        self.date = date
        
        if configuration.Include_food_trucks == true {
            self.data = data
        } else {
            self.data = data.filter({ restaurant in
                restaurant.name.lowercased().contains("food truck") == false
            })
        }
        self.nextMealOpening = nextMealOpening
        self.configuration = configuration
    }
}

struct DiningWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            Color("blue")
            VStack() {
                if entry.data == [] {
                    Text(entry.nextMealOpening)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .padding()
                        .fontWeight(.bold)
                        .opacity(0.7)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Open now")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.leading])
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Image("icon_small")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding([.top, .trailing, .bottom])
                        }
                        .frame(height: 50)
                        .padding(.bottom, -10)
                        
                        switch widgetFamily {
                        case .systemSmall:
                            if entry.data.count < 6 {
                                ForEach(Array(entry.data), id: \.self) { openRestaurant in
                                    HStack(spacing: 0) {
                                        Text(openRestaurant.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                            .fontWeight(.regular)
                                            .font(.system(size: 12))
                                            .lineLimit(nil)
                                            .minimumScaleFactor(0.5)
                                        Text(openRestaurant.closingTime)
                                            .frame(alignment: .trailing)
                                            .foregroundColor(.white)
                                            .fontWeight(.light)
                                            .font(.system(size: 10))
                                            .opacity(0.8)
                                    }
                                    .padding([.leading, .trailing])
                                    Spacer(minLength: 6)
                                }
                                .fixedSize(horizontal: false, vertical: true)

                            } else {
                                ForEach(Array(entry.data), id: \.self) { openRestaurant in
                                    HStack(spacing: 0) {
                                        Text(openRestaurant.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                            .fontWeight(.regular)
                                            .font(.system(size: 12))
                                            .lineLimit(nil)
                                            .minimumScaleFactor(0.5)
                                        Text(openRestaurant.closingTime)
                                            .frame(alignment: .trailing)
                                            .foregroundColor(.white)
                                            .fontWeight(.light)
                                            .font(.system(size: 10))
                                            .opacity(0.8)
                                    }
                                    .padding([.leading, .trailing])
                                    Spacer(minLength: 3)
                                }
                            }

                        case .systemMedium:
                            let even = stride(from: 0, to: entry.data.count, by: 2).map { entry.data[$0] }
                            let odd = stride(from: 1, to: entry.data.count, by: 2).map { entry.data[$0] }
                            
                            HStack(spacing: 17) {
                                VStack {
                                    ForEach(Array(even), id: \.self) { openRestaurant in
                                        HStack(spacing: 0) {
                                            Text(openRestaurant.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.white)
                                                .fontWeight(.regular)
                                                .font(.system(size: 12))
                                                .lineLimit(nil)
                                                .minimumScaleFactor(0.5)
                                            Text(openRestaurant.closingTime)
                                                .frame(alignment: .trailing)
                                                .foregroundColor(.white)
                                                .fontWeight(.light)
                                                .font(.system(size: 10))
                                                .opacity(0.8)
                                        }
                                        .padding(.leading)
                                        Spacer(minLength: 5)
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
    
                                VStack {
                                    ForEach(Array(odd), id: \.self) { openRestaurant in
                                        HStack(spacing: 0) {
                                            Text(openRestaurant.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.white)
                                                .fontWeight(.regular)
                                                .font(.system(size: 12))
                                                .lineLimit(nil)
                                                .minimumScaleFactor(0.5)
                                            Text(openRestaurant.closingTime)
                                                .frame(alignment: .trailing)
                                                .foregroundColor(.white)
                                                .fontWeight(.light)
                                                .font(.system(size: 10))
                                                .opacity(0.8)
                                        }
                                        .padding(.trailing)
                                        Spacer(minLength: 5)
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        default: Text("Hmm... This isn't supposed to happen. :/ Let me know at mariusgenton@gmail.com!")
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}


@main
struct BruinDining_Widget: Widget {
    let kind: String = "BruinDining_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            DiningWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Open dining halls")
        .description("Displays the dinings halls and food trucks that are currently open along with their closing time.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BruinDining_Widget_Previews: PreviewProvider {
    static var previews: some View {
        DiningWidgetEntryView(entry: SimpleEntry(date: Date(), data: SampleEntryData, configuration: ConfigurationIntent(), nextMealOpening: ""))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
