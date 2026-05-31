# frozen_string_literal: true

namespace :sbv do
  desc "Assign Super-Administrator role to a person by email (default: simon@betschmann.ch)"
  task :assign_super_admin, [:email] => :environment do |_task, args|
    email = args[:email].presence || "simon@betschmann.ch"
    person = Person.find_by(email: email)

    abort "Person with email #{email} not found" unless person

    [
      [Group::Root.first, Group::Root::SuperAdmin],
      [Group::Generalverband.first, Group::Generalverband::SuperAdmin]
    ].each do |group, role_type|
      next unless group

      role = Role.find_or_initialize_by(
        person: person,
        group: group,
        type: role_type.sti_name
      )
      role.save!
      puts "Assigned #{role_type.sti_name} on #{group} to #{person.full_name} (#{email})"
    end
  end
end
