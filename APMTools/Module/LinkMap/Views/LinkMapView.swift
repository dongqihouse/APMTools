//
//  LinkMapViews.swift
//  Created on 2022/7/15
//  Drayl  
//

import SwiftUI

struct LinkMapView: View {
    @State var isTargeted = false
    @EnvironmentObject var viewModel: LinkMapViewModel
    
    @State var isLoading = false
    var body: some View {

            ZStack {
                contentView()
                addView().opacity(0)
            }
        
    }
    
    @ViewBuilder
    func addView() -> some View {
        Rectangle()
            .foregroundColor(.gray)
            .frame(width: 10000, height: 10000)
            .position(x: 0, y: 0)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers -> Bool in
                if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                    let _ = provider.loadObject(ofClass: URL.self) { object, error in
                        if let url = object {
                            update(url: url.path)
                        }
                    }
                    return true
                }
                return true
            }
    }
    
    @ViewBuilder
    func contentView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    analyze()
                }, label: {
                    Image("begin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                })
                .buttonStyle(.borderless)
                Spacer()
            }
            TabView {
                LinkMapList(items: $viewModel.fileObjects)
                    .tabItem {
                        Label("单文件列表", systemImage: "tray.and.arrow.down.fill")
                    }
                LinkMapList(items: $viewModel.moduleObjects)
                    .tabItem {
                        Label("模块列表", systemImage: "tray.and.arrow.down.fill")
                    }
            }
            Spacer()
            Text(viewModel.filePath.isEmpty ? "请拖入LinkMap文件...." : viewModel.filePath).font(.system(size: 12))
        }
        .padding([.trailing,.leading])
    }
    
    func analyze() {
        Task.detached {
            do {
                await self.viewModel.set(loading: true)
                let linkMap = try await LinkMapUtil.analyze(with: self.viewModel.filePath)
                await self.viewModel.set(moduleObjects: LinkMapUtil.sortedCombineSymbols(from: linkMap))
                await self.viewModel.set(fileObjects: LinkMapUtil.sortedSymbols(from: linkMap))
                await self.viewModel.set(loading: false)
            } catch {
                await self.viewModel.set(loading: false)
                print(error)
            }
        }
    }
    
    @MainActor
    func update(url: String) {
        viewModel.filePath = url
    }
}

struct LinkMapList: View {
    @Binding var items: [LinkMapItem]
    
    var body: some View {
        List(items, id: \.name) { file in
            HStack {
                Text(file.name)
                    .frame(width: 200, alignment: .leading)
                Spacer()
                    .frame(width: 100)
                Text(String(format: "%.2fK", Double(file.size) / 1024.0))
            }
        }
    }
}
