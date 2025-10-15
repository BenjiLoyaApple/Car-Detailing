//
//  EditContacts.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 15.08.2025.
//

import SwiftUI

struct EditContactsView: View {

    @Environment(\.dismiss) private var dismiss
    
    // Входные значения
    let initialEmail: String
    let initialPhone: String?
    let initialCity:  City
    let initialAvatarURL: String?
    let initialAvatarData: Data?

    /// Колбэк сохранения:
    /// avatarData — сырые данные, если пользователь поменял аватар (или nil — без изменений)
    /// Примечание: city остаётся String для обратной совместимости, передаём displayName.
    let onSave: (_ email: String,
                 _ phone: String?,
                 _ city: String,
                 _ avatarData: Data?) -> Void

    // Локальные состояния
    @State private var emailAddress: String
    @State private var phoneNumber: String
    @State private var city: City
    @State private var userImageData: Data?       // локальный аватар
    @State private var isSaving = false

    // Флаги для корректной логики изменения аватара
    @State private var avatarChanged = false
    @State private var isBootstrappingAvatar = false

    init(
        initialEmail: String,
        initialPhone: String?,
        initialCity: City,
        initialAvatarURL: String? = nil,
        initialAvatarData: Data? = nil,
        onSave: @escaping (_ email: String, _ phone: String?, _ city: String, _ avatarData: Data?) -> Void
    ) {
        self.initialEmail = initialEmail
        self.initialPhone = initialPhone
        self.initialCity = initialCity
        self.initialAvatarURL = initialAvatarURL
        self.initialAvatarData = initialAvatarData
        self.onSave = onSave

        _emailAddress = State(initialValue: initialEmail)
        _phoneNumber  = State(initialValue: initialPhone ?? "")
        _city         = State(initialValue: initialCity)
        _userImageData = State(initialValue: initialAvatarData) // ⬅️ стартуем с переданных Data
    }

    var body: some View {
        NavigationStack {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                /// Header
                HStack {
                    CircleButton(
                        systemImageName: "chevron.left"
                    ) {
                        //      router.dismissScreen()
                        dismiss()
                    }
                    
                    Spacer(minLength: 0)
                    
                    Text("Edit contacts")
                        .font(.system(size: 20, weight: .semibold))
                        .fontWidth(.condensed)
                    
                    Spacer(minLength: 0)
                    
                    CircleButton(
                        systemImageName: "checkmark"
                    ) {
                        guard canSave else { return }
                        save()
                    }
                    .disabled(!canSave)
                }
                .frame(height: 40)
                .padding(.horizontal, 15)
                
                /// Аватар
                HStack {
                    //                    AvatarView(
                    //                        imageURL: initialAvatarURL,   // URL как резерв
                    //                        imageData: $userImageData,    // но приоритет у Data, если есть
                    //                        fullName: "",
                    //                        width: 100, height: 100,
                    //                        shape: .circle,
                    //                        showBorder: true,
                    //                        isEditable: true
                    //                    )
                    //                    .padding(.top, 10)
                    //                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom)
                
                /// Поля
                Group {
                    EditableTextField(label: "Email", text: $emailAddress, keyboardType: .emailAddress)
                    EditableTextField(label: "Phone", text: $phoneNumber, keyboardType: .phonePad)
                    
                    // ВЫБОР ГОРОДА (типобезопасный)
                    LabeledPickerRow(
                        label: "City",
                        selection: $city,
                        options: City.allCases,
                        displayName: { $0.displayName }
                    )
                }
                .padding(.horizontal, 15)
                
                Spacer(minLength: 0)
            }
            .background(Color.theme.themeBG)
            .task { await bootstrapAvatarIfNeeded() } // ⬅️ грузим URL ТОЛЬКО если нет Data
            .onChange(of: userImageData) { _, _ in
                // засчитываем изменение аватара только если это не первичная подгрузка
                if !isBootstrappingAvatar { avatarChanged = true }
            }
            
            if isSaving {
                SavingOverlay()
            }
        }
    }
    }

    // MARK: - Валидация и сохранение
    private var phoneNormalized: String? {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var emailValid: Bool {
        let trimmed = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && !trimmed.hasPrefix("@") && !trimmed.hasSuffix("@")
    }

    private var hasChanges: Bool {
        emailAddress.trimmingCharacters(in: .whitespacesAndNewlines) != initialEmail ||
        phoneNormalized != initialPhone ||
        city != initialCity ||
        avatarChanged
    }

    private var canSave: Bool { emailValid && hasChanges }

    private func save() {
        isSaving = true
        let email = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNormalized
        let cityValue = city.displayName
        let avatar = avatarChanged ? userImageData : nil   // отдаём данные только если реально меняли

        Task {
            try? await Task.sleep(for: .milliseconds(600))
            onSave(email, phone, cityValue, avatar)
            isSaving = false
         //   router.dismissScreen()
            dismiss()
            HapticManager.instance.impact(style: .light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                Toast.shared.present(
                    title: "Contacts updated",
                    symbol: "at",
                    isUserInteractionEnabled: true,
                    timing: .short
                )
            }
        }
    }

    // MARK: - Бутстрап аватара
    private func bootstrapAvatarIfNeeded() async {
        // Если у нас уже есть Data (передали из профиля) — НИЧЕГО не грузим по URL.
        guard userImageData == nil,
              let urlString = initialAvatarURL,
              let url = URL(string: urlString) else { return }
        do {
            isBootstrappingAvatar = true
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                userImageData = data
                isBootstrappingAvatar = false
            }
        } catch {
            isBootstrappingAvatar = false
            print("Failed to load avatar:", error)
        }
    }
}

#Preview {
    EditContactsView(
        initialEmail: "john.smith@example.com",
        initialPhone: "+1 (277) 455 1693",
        initialCity: .yekaterinburg,
//        initialAvatarURL: "https://picsum.photos/200/200",
        initialAvatarData: nil
    ) { _,_,_,_ in }
}
