//
//  EditableFields.swift
//  Document
//
//  Created by Benji Loya on 06.03.2025.
//

import SwiftUI

struct EditableTextField: View {
    var label: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    
    // Новый инициализатор для опциональных значений
    init(label: String, text: Binding<String?>, axis: Axis = .horizontal, placeholder: String = "", keyboardType: UIKeyboardType = .default) {
        self.label = label
        self._text = Binding(
            get: { text.wrappedValue ?? "" },
            set: { text.wrappedValue = $0.isEmpty ? nil : $0 }
        )
        self.axis = axis
        self.placeholder = placeholder.isEmpty ? Self.getPlaceholder(for: label) : placeholder
        self.keyboardType = keyboardType
    }
    
    // Старый инициализатор для совместимости
    init(label: String, text: Binding<String>, axis: Axis = .horizontal, placeholder: String = "", keyboardType: UIKeyboardType = .default) {
        self.label = label
        self._text = text
        self.axis = axis
        self.placeholder = placeholder.isEmpty ? Self.getPlaceholder(for: label) : placeholder
        self.keyboardType = keyboardType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.gray)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.gray.opacity(0.6)), axis: axis)
                .font(.system(size: 16))
                .padding(.vertical, 4)
                .keyboardType(keyboardType)

            Divider().opacity(0.4)
        }
    }

    // Обновленная функция с новыми плейсхолдерами
    private static func getPlaceholder(for label: String) -> String {
        switch label {
        case "Full Name": return "John Doe"
        case "Email": return "example@email.com"
        case "Phone": return "+1 (555) 123-4567"
        case "City, State": return "New York, NY"
        default: return ""
        }
    }
}


struct LabeledPickerRow<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [T]
    let displayName: (T) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)

            Menu {
                ForEach(options, id: \.self) { item in
                    Button {
                        selection = item
                    } label: {
                        Text(displayName(item))
                    }
                }
            } label: {
                HStack {
                    Text(displayName(selection))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            Divider()
                .opacity(0.4)
        }
    }
}

// Обновленный EditableDatePicker с поддержкой опциональных значений
struct EditableDatePicker: View {
    var label: String
    @Binding var date: Date?
    var defaultDate: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.gray)

            DatePicker("", selection: Binding(
                get: { date ?? defaultDate },
                set: { date = $0 }
            ), displayedComponents: .date)
            .labelsHidden()

            Divider().opacity(0.4)
        }
    }
}

