# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module PersonConstraints
    extend ActiveSupport::Concern

    private

    def readable_in_same_layer
      super || permission_via_verein_layer_hierarchy?(readable_layer_groups)
    end

    def non_restricted_in_same_layer
      super || permission_via_verein_layer_hierarchy?(non_restricted_layer_groups)
    end

    def in_same_layer
      super || permission_via_verein_layer_hierarchy?(person.layer_groups)
    end

    def permission_via_verein_layer_hierarchy?(layer_groups)
      layer_groups.any? do |layer_group|
        layer_group.is_a?(::Group::Verein) &&
          permission_in_layers?(layer_group.layer_hierarchy.map(&:id))
      end
    end

    def readable_layer_groups
      person.groups_with_roles_ended_readable.map(&:layer_group).uniq
    end

    def non_restricted_layer_groups
      person.non_restricted_groups.map(&:layer_group).uniq
    end
  end
end
