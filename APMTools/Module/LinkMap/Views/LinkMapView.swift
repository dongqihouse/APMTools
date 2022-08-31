//
//  LinkMapViews.swift
//  Created on 2022/7/15
//  Drayl  
//

import SwiftUI

struct LinkMapView: View {
    @State var isTargeted = false
    @EnvironmentObject var viewModel: LinkMapViewModel
    
    var body: some View {
        
        ZStack {
            contentView()
            if viewModel.filePath.isEmpty {
                AddView(callback: { path in
                    viewModel.filePath = path
                }).frame(width: 500, height: 500)
            }
            
        }
    }
        
    
    @ViewBuilder
    func contentView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
                    Button(action: {
                        analyze()
                    }, label: {
                        Image(systemName: "play.square.fill")
                            .font(.system(size: 30))
                    })
                        .buttonStyle(.borderless)
                }
                
                Spacer().frame(width: 20)
                Button(action: {
                    viewModel.contentSelectedIndex = 0
                }, label: {
                  Text("单文件列表")
                        .foregroundColor(viewModel.contentSelectedIndex == 0 ? .white : .gray)
                })
                .buttonStyle(.borderless)
                Button(action: {
                    viewModel.contentSelectedIndex = 1
                }, label: {
                    Text("模块列表")
                        .foregroundColor(viewModel.contentSelectedIndex == 1 ? .white : .gray)
                })
                    .buttonStyle(.borderless)
                
                
                Spacer()
            }.frame(height: 50)
            if viewModel.contentSelectedIndex == 0 {
                LinkMapList(items: $viewModel.fileObjects)
            } else {
                LinkMapList(items: $viewModel.moduleObjects)
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
                await self.viewModel.set(contentSelectedIndex: 0)
            } catch {
                await self.viewModel.set(loading: false)
                print(error)
            }
        }
    }
}

struct LinkMapList: View {
    @Binding var items: [LinkMapItem]
    
    var body: some View {
        List(items, id: \.name) { file in
            HStack {
                Text(file.name)
                    .frame(width: 400, alignment: .leading)
                Spacer()
                Text(String(format: "%.2fK", Double(file.size) / 1024.0))
            }
        }
    }
}
