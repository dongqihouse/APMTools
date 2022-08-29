//
//  ContentView.swift
//  CrashTools
//
//  Created by Drayl on 2022/4/6.
//

import SwiftUI

class SideItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: SideItem, rhs: SideItem) -> Bool {
        lhs.title == rhs.title && lhs.imageName == rhs.imageName
    }
    
    let title: String
    let imageName: String
    var view: AnyView? = nil
    
    init(title: String, imageName: String, view: AnyView? = nil) {
        self.title = title
        self.imageName = imageName
    }
}

struct ContentView: View {
    @State var currentSelectedItemIndex: Int = 0
    
    @StateObject var linkMapViewModel = LinkMapViewModel()
    
    let sideItems: [SideItem] = [
        .init(title: "LinkMap分析", imageName: "p1"),
        .init(title: "Crash解析", imageName: "p2"),
        .init(title: "资源压缩", imageName: "p3"),
        .init(title: "启动分析", imageName: "p4"),
        .init(title: "OTool分析", imageName: "p5"),
        .init(title: "Logan解析", imageName: "p6")
    ]
    
    var body: some View {
        NavigationView {
            LeftListView(currentSelectedItem: $currentSelectedItemIndex, sideItems: sideItems)
            getItemDetail()
        }
    
    }
    
    @ViewBuilder
    func getItemDetail() -> some View {
        if let view = sideItems[currentSelectedItemIndex].view {
            view
        }
        
        switch currentSelectedItemIndex {
        case 0:
            LinkMapView().environmentObject(linkMapViewModel)
        default:
            Text("Other")
        }
        Text("")
    }
}

struct LeftListView: View {
    @Binding var currentSelectedItem: Int
    
    let sideItems: [SideItem]
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            ForEach(sideItems.indices, id: \.self) { index in
                let current = sideItems[currentSelectedItem]
                let option = sideItems[index]
                HStack {
                    Image(option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                    
                    Text(option.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(current == option ? .white : .gray)
                        .frame(width: 120, alignment: .leading)
                    
                    Spacer()
                }
                .padding(8)
                .onTapGesture {
                    currentSelectedItem = index
                }
            }
            Spacer()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
