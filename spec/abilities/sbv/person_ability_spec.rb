# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe PersonAbility do
  subject { ability }

  let(:ability) { Ability.new(role.person.reload) }
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:mitglieder) { groups(:mitglieder_38) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:member) do
    Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: mitglieder)
  end

  before do
    verein.update!(secondary_parent_id: secondary_mitgliederverband.id)
  end

  context "Mitgliederverband admin of secondary parent" do
    let(:role) do
      Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
        group: secondary_mitgliederverband)
    end

    it "may show a person in the secondary affiliated verein" do
      is_expected.to be_able_to(:show, member.person)
    end

    it "may show full details of a person in the secondary affiliated verein" do
      is_expected.to be_able_to(:show_full, member.person)
    end

    it "may update a person in the secondary affiliated verein" do
      is_expected.to be_able_to(:update, member.person)
    end
  end

  context "Mitgliederverband admin without secondary affiliation" do
    let(:role) do
      Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
        group: secondary_mitgliederverband)
    end

    before do
      verein.update!(secondary_parent_id: nil, tertiary_parent_id: nil)
    end

    it "may not show a person in the verein" do
      is_expected.not_to be_able_to(:show, member.person)
    end
  end
end
