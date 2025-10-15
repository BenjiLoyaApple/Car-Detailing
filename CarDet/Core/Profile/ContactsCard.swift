//
//  ContactsCard.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 14.08.2025.
//

import SwiftUI

struct ContactInfoCard: View {
    var title: String = "Personal Info"
    var icon: String = "at"

    var email: String? = "john.smith@example.com"
    var phone: String? = "+1 (277) 455 1693"
    var city: City
    
    var body: some View {
        Card {
            CardHeader(icon: icon, title: title)

            if let email {
                InfoRow(icon: "envelope.fill", title: "Email", value: email)
            }
            
            if let phone {
                InfoRow(icon: "phone.fill", title: "Phone", value: phone)
            }

            InfoRow(icon: "mappin.and.ellipse", title: "City", value: city.displayName)

        }
    }
}

#Preview("ContactInfoCard – custom / no phone") {
    VStack(spacing: 20) {
        
        ContactInfoCard(
                 email: UserModel.mock.emailAddress,
                 phone: UserModel.mock.phoneNumber,
                 city: UserModel.mock.city,
             )
        
        ContactInfoCard(
            email: "emily.j@example.com",
            phone: nil,
            city: City.ufa,
        )
        
        ContactInfoCard(
            email: nil,
            phone: "+1 (123`456) 123-456",
            city: City.yekaterinburg,
        )
        
        ContactInfoCard(
            email: "emily.j@example.com",
            phone: "+1 (123`456) 123-456",
            city: City.yekaterinburg,
        )
        
    }
    .padding()
    .background(Color.themeBG)
}
