# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe PersonReadables do
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:mitglieder) { groups(:mitglieder_38) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:member) do
    Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: mitglieder)
  end
  let(:role) do
    Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
      group: secondary_mitgliederverband)
  end
  let(:user) { role.person.reload }
  let(:ability) { described_class.new(user) }
  let(:accessible) { Person.accessible_by(ability) }

  before do
    verein.update!(secondary_parent_id: secondary_mitgliederverband.id)
  end

  context "global listing with secondary parent affiliation" do
    it "includes members of secondary affiliated vereins" do
      expect(accessible).to include(member.person)
    end

    context "without secondary affiliation" do
      before do
        verein.update!(secondary_parent_id: nil, tertiary_parent_id: nil)
      end

      it "does not include members of the verein" do
        expect(accessible).not_to include(member.person)
      end
    end
  end
end

describe PersonFullReadables do
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:mitglieder) { groups(:mitglieder_38) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:member) do
    Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: mitglieder)
  end
  let(:role) do
    Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
      group: secondary_mitgliederverband)
  end
  let(:user) { role.person.reload }
  let(:ability) { described_class.new(user) }
  let(:accessible) { Person.accessible_by(ability) }

  before do
    verein.update!(secondary_parent_id: secondary_mitgliederverband.id)
  end

  it "includes members of secondary affiliated vereins" do
    expect(accessible).to include(member.person)
  end
end

describe SearchStrategies::PersonSearch do
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:mitglieder) { groups(:mitglieder_38) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:member) do
    Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: mitglieder).person.tap do |person|
      person.update_columns(last_name: person.last_name * 3, first_name: person.first_name * 3)
    end
  end
  let(:role) do
    Fabricate(Group::Mitgliederverband::Admin.sti_name.to_sym,
      group: secondary_mitgliederverband)
  end
  let(:user) { role.person.reload }

  before do
    verein.update!(secondary_parent_id: secondary_mitgliederverband.id)
  end

  it "finds members of secondary affiliated vereins" do
    result = described_class.new(user, member.last_name[0..5], nil).search

    expect(result).to include(member)
  end
end
