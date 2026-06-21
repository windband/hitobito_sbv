# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe GroupAbility do
  subject { ability }

  let(:ability) { Ability.new(role.person.reload) }
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }

  before do
    verein.update!(secondary_parent: secondary_mitgliederverband)
  end

  context "Mitgliederverband admin of secondary parent" do
    let(:role) do
      Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
        group: secondary_mitgliederverband)
    end

    it "may update the verein" do
      is_expected.to be_able_to(:update, verein)
    end

    it "may show details of the verein" do
      is_expected.to be_able_to(:show_details, verein)
    end

    it "may manage roles in the verein" do
      mitglieder = groups(:mitglieder_38)
      role_in_verein = Fabricate(
        Group::VereinMitglieder::Mitglied.sti_name.to_sym,
        group: mitglieder
      )

      is_expected.to be_able_to(:update, role_in_verein)
      is_expected.to be_able_to(:index_people, mitglieder)
    end
  end

  context "Mitgliederverband admin without secondary affiliation" do
    let(:role) do
      Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
        group: secondary_mitgliederverband)
    end

    before do
      verein.update!(secondary_parent: nil, tertiary_parent: nil)
    end

    it "may not update the verein" do
      is_expected.not_to be_able_to(:update, verein)
    end
  end
end
