# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module GroupBasedFetchables
    extend ActiveSupport::Concern

    SECONDARY_PARENT_LAYER_PERMISSIONS = [
      :layer_and_below_read, :layer_and_below_full, :layer_read, :layer_full
    ].freeze

    private

    def append_group_conditions(condition)
      super
      in_secondary_parent_verein_condition(condition)
    end

    def in_secondary_parent_verein_condition(condition)
      layer_ids = secondary_parent_access_layer_ids
      return if layer_ids.blank?

      verein_layer_ids = secondary_parent_verein_layer_group_ids(layer_ids)
      return if verein_layer_ids.blank?

      condition.or(
        "#{Group.quoted_table_name}.layer_group_id IN (?)",
        verein_layer_ids
      )
    end

    def secondary_parent_access_layer_ids
      layer_group_ids_with_permissions(*SECONDARY_PARENT_LAYER_PERMISSIONS)
    end

    def secondary_parent_verein_layer_group_ids(layer_ids)
      ::Group::Verein
        .where(secondary_parent_id: layer_ids)
        .or(::Group::Verein.where(tertiary_parent_id: layer_ids))
        .pluck(:id)
    end
  end
end
