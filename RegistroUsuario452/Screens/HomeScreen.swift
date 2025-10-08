//
//  HomeScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 13/09/25.
//


import SwiftUI

struct HomeScreen: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var selectedTab = 0
    @State private var showCreateReport = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenido principal
            TabView(selection: $selectedTab) {
                // Tab 1: Reportes Aceptados
                AcceptedReportsView()
                    .tag(0)
                
                // Tab 2: Espacio para el botón flotante
                Color.clear
                    .tag(1)
                
                // Tab 3: Perfil
                ProfileMenuView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                // Botón Reportes
                TabBarButton(
                    icon: "list.bullet.clipboard",
                    title: "Reportes",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                .frame(maxWidth: .infinity)
                
                // Botón Crear (central)
                Button(action: {
                    showCreateReport = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -20)
                .frame(maxWidth: .infinity)
                
                // Botón Perfil
                TabBarButton(
                    icon: "person.circle",
                    title: "Perfil",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showCreateReport) {
            CreateReportView()
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .red : .gray)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .red : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeScreen()
}
