# frozen_string_literal: true

#  Copyright (c) 2012-2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupResource
  extend ActiveSupport::Concern

  # Verein-specific group columns; enum fields expose stored keys (not labels).
  VEREIN_ATTRIBUTES = {
    vereinssitz: :string,
    founding_year: :integer,
    besetzung: :string,
    klasse: :string,
    unterhaltungsmusik: :string,
    subventionen: :string,
    manually_counted_members: :boolean,
    manual_member_count: :integer,
    recognized_members: :integer,
    secondary_parent_id: :integer,
    tertiary_parent_id: :integer
  }.freeze

  included do
    VEREIN_ATTRIBUTES.each do |name, type|
      attribute name, type, writable: false
    end
  end
end
