//
//  LinkMapViews.swift
//  Created on 2022/7/15
//  Drayl  
//

import SwiftUI

struct LinkMapView: View {
    
    @EnvironmentObject var viewModel: LinkMapViewModel
    
    @State var isLoading = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                InputContentView(fileUrl: $viewModel.filePath)
                VStack {
                    Button("开始分析") {
                        Task.detached {
                            do {
                                await self.viewModel.set(loading: true)
                                let linkMap = try await LinkMapUtil.analyze(with: self.viewModel.filePath)
                                let objectFiles = LinkMapUtil.sortedCombineSymbols(from: linkMap)
                                await self.viewModel.set(fileObjects: objectFiles)
                                await self.viewModel.set(loading: false)
                            } catch {
                                await self.viewModel.set(loading: false)
                                print(error)
                            }
                        }
                    }
                    if isLoading {
                        ProgressView()
                    }
                }
            }
            TabView {
                LinkMapList(objectFiles: $viewModel.fileObjects)
                    .tabItem {
                        Label("大文件排名", systemImage: "tray.and.arrow.down.fill")
                    }
                LinkMapList(objectFiles: $viewModel.fileObjects)
                    .tabItem {
                        Label("+load方法列表", systemImage: "tray.and.arrow.down.fill")
                    }
            }
            
        }
        Spacer()
    }
}

struct InputContentView: View {
    @State var isTargeted = false
    @Binding var fileUrl: String
    
    var body: some View {
        Text(fileUrl.count == 0 ? "拖动LinkMap文件到此" : fileUrl)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .frame(width: 600, height: 100)
            .border(Color.green)
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
    
    @MainActor
    func update(url: String) {
        fileUrl = url
    }
}

struct LinkMapList: View {
    @Binding var objectFiles: [ModuleFile]
    
    var body: some View {
        List(objectFiles, id: \.self) { file in
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
