// AbilitiesEditor.swift
// Sentinel Worlds Editor - Swift Port
//
// Copyright (C) 2025 Lee R.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.

import SwiftUI

/// Editor for crew member abilities
struct AbilitiesEditor: View {
    let crew: CrewMember
    let onChanged: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(crew.name) - Abilities")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    ValidatedNumberField(
                        label: "Contact",
                        value: Binding(
                            get: { crew.abilities.contact },
                            set: { crew.abilities.contact = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Edged",
                        value: Binding(
                            get: { crew.abilities.edged },
                            set: { crew.abilities.edged = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Projectile",
                        value: Binding(
                            get: { crew.abilities.projectile },
                            set: { crew.abilities.projectile = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Blaster",
                        value: Binding(
                            get: { crew.abilities.blaster },
                            set: { crew.abilities.blaster = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Tactics",
                        value: Binding(
                            get: { crew.abilities.tactics },
                            set: { crew.abilities.tactics = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Recon",
                        value: Binding(
                            get: { crew.abilities.recon },
                            set: { crew.abilities.recon = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Gunnery",
                        value: Binding(
                            get: { crew.abilities.gunnery },
                            set: { crew.abilities.gunnery = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "ATV Repair",
                        value: Binding(
                            get: { crew.abilities.atvRepair },
                            set: { crew.abilities.atvRepair = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Mining",
                        value: Binding(
                            get: { crew.abilities.mining },
                            set: { crew.abilities.mining = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Athletics",
                        value: Binding(
                            get: { crew.abilities.athletics },
                            set: { crew.abilities.athletics = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Observation",
                        value: Binding(
                            get: { crew.abilities.observation },
                            set: { crew.abilities.observation = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )

                    ValidatedNumberField(
                        label: "Bribery",
                        value: Binding(
                            get: { crew.abilities.bribery },
                            set: { crew.abilities.bribery = $0 }
                        ),
                        range: 0...SaveFileConstants.MaxValues.stat,
                        onChange: onChanged
                    )
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
