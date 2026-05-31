# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe "Super-Administrator" do
  let(:dachverband) { groups(:hauptgruppe_1) }
  let(:mitgliederverband) { groups(:bernischer_kantonal_musikverband) }
  let(:vorstand) { groups(:vorstand_10) }
  let(:mailing_list) { Fabricate(:mailing_list, group: vorstand, name: "Präsidenten") }

  describe "mailing list access in lower layers" do
    context "with super admin role on dachverband" do
      let(:role) { Fabricate(Group::Root::SuperAdmin.name.to_sym, group: dachverband) }
      let(:ability) { Ability.new(role.person.reload) }

      it "may show mailing lists in lower layers" do
        expect(ability).to be_able_to(:show, mailing_list)
      end

      it "may update mailing lists in lower layers" do
        expect(ability).to be_able_to(:update, mailing_list)
      end

      it "may index subscriptions in lower layers" do
        expect(ability).to be_able_to(:index_subscriptions, mailing_list)
      end

      it "may impersonate users" do
        other = people(:member)
        expect(ability).to be_able_to(:impersonate_user, other)
      end
    end

    context "with regular admin role on dachverband" do
      let(:role) { Fabricate(Group::Root::Admin.name.to_sym, group: dachverband) }
      let(:ability) { Ability.new(role.person.reload) }

      it "may not show mailing lists in lower layers" do
        expect(ability).not_to be_able_to(:show, mailing_list)
      end

      it "may not update mailing lists in lower layers" do
        expect(ability).not_to be_able_to(:update, mailing_list)
      end
    end
  end

  describe "role assignment protection" do
    let(:target_person) { people(:member) }
    let(:super_admin_role) do
      Fabricate(Group::Root::SuperAdmin.name.to_sym, group: dachverband)
    end
    let(:regular_admin_role) do
      Fabricate(Group::Root::Admin.name.to_sym, group: dachverband)
    end

    it "allows super admins to assign super admin roles" do
      ability = Ability.new(super_admin_role.person.reload)
      new_role = Group::Root::SuperAdmin.new(group: dachverband, person: target_person)

      expect(ability).to be_able_to(:create, new_role)
    end

    it "prevents regular admins from assigning super admin roles" do
      ability = Ability.new(regular_admin_role.person.reload)
      new_role = Group::Root::SuperAdmin.new(group: dachverband, person: target_person)

      expect(ability).not_to be_able_to(:create, new_role)
    end

    it "prevents regular admins from removing super admin roles" do
      ability = Ability.new(regular_admin_role.person.reload)

      expect(ability).not_to be_able_to(:destroy, super_admin_role)
    end
  end

  describe Sbv::MailingListReadables do
    let(:role) { Fabricate(Group::Root::SuperAdmin.name.to_sym, group: dachverband) }
    let(:readables) { Sbv::MailingListReadables.new(role.person.reload) }

    before { mailing_list }

    it "includes mailing lists from lower layers" do
      expect(readables.can?(:index, mailing_list)).to be(true)
    end
  end
end
