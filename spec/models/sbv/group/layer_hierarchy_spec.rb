# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Group, "#layer_hierarchy" do
  let(:verein) { groups(:musikgesellschaft_alterswil) }
  let(:secondary_mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:tertiary_regionalverband) { groups(:regionalverband_mittleres_seeland) }

  before do
    verein.update!(
      secondary_parent_id: secondary_mitgliederverband.id,
      tertiary_parent_id: tertiary_regionalverband.id
    )
  end

  it "includes layers from secondary and tertiary parents for the verein" do
    secondary_layers = secondary_mitgliederverband.layer_hierarchy.map(&:id)
    tertiary_layers = tertiary_regionalverband.layer_hierarchy.map(&:id)

    expect(verein.layer_hierarchy.map(&:id)).to include(*secondary_layers, *tertiary_layers)
  end

  it "includes secondary parent layers for subgroups of the verein" do
    mitglieder = groups(:mitglieder_38)

    expect(mitglieder.layer_hierarchy.map(&:id)).to include(secondary_mitgliederverband.id)
  end

  it "does not change layer hierarchy for groups without secondary parents" do
    regionalverband = groups(:alt_thiesdorf_30)
    expected_layer_ids = regionalverband.hierarchy.select { |g| g.class.layer }.map(&:id)

    expect(regionalverband.layer_hierarchy.map(&:id)).to eq(expected_layer_ids)
  end
end
