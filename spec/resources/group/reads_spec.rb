# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe GroupResource, type: :resource do
  let(:person) { people(:admin) }

  describe "Verein attributes" do
    let(:verein) { groups(:musikgesellschaft_alterswil) }

    before do
      params[:filter] = {id: {eq: verein.id}}
    end

    it "returns SBV Verein fields as stored values" do
      verein.update!(
        vereinssitz: "Alterswil",
        founding_year: 1920,
        besetzung: :harmonie,
        klasse: :erste,
        unterhaltungsmusik: :oberstufe,
        subventionen: "Kanton SG"
      )

      render

      data = jsonapi_data[0]
      expect(data.vereinssitz).to eq("Alterswil")
      expect(data.founding_year).to eq(1920)
      expect(data.besetzung).to eq("harmonie")
      expect(data.klasse).to eq("erste")
      expect(data.unterhaltungsmusik).to eq("oberstufe")
      expect(data.subventionen).to eq("Kanton SG")
    end

    it "returns blank enum keys when not set" do
      verein.update!(
        besetzung: nil,
        klasse: nil,
        unterhaltungsmusik: nil
      )

      render

      data = jsonapi_data[0]
      expect(data.besetzung).to be_blank
      expect(data.klasse).to be_blank
      expect(data.unterhaltungsmusik).to be_blank
    end
  end
end
