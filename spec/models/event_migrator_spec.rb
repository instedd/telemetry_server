require 'rails_helper'

RSpec.describe EventMigrator, type: :model do
  let(:migrator) { EventMigrator.new }

  def migrate_counter(original, migrated)
    migrator.migrate_counter original
    expect(original).to eq(migrated)
  end

  it "does not touch the counter no rules applies" do
    migrate_counter(
      { 'metric' => 'foo', 'key' => { 'bar' => 2 }, 'value' => 3 },
      { 'metric' => 'foo', 'key' => { 'bar' => 2 }, 'value' => 3 })
  end

  it "migrates mbuilder numbers_by_application_and_country" do
    migrate_counter(
      { 'metric' => 'numbers_by_application_and_country', 'key' => { 'application_id' => 42, 'country_code' => '54' }, 'value' => 38 },
      { 'metric' => 'unique_phone_numbers_by_project_and_country', 'key' => { 'project_id' => 42, 'country_code' => '54' }, 'value' => 38 })
  end

  it "migrates verboice callers" do
    migrate_counter(
      { 'metric' => 'callers', 'key' => { 'project_id' => 42, 'country_code' => '54' }, 'value' => 38 },
      { 'metric' => 'unique_phone_numbers_by_project_and_country', 'key' => { 'project_id' => 42, 'country_code' => '54' }, 'value' => 38 })
  end

  it "migrates pollit callers" do
    migrate_counter(
      { 'metric' => 'numbers_by_country_code', 'key' => { 'country_code' => '54' }, 'value' => 38 },
      { 'metric' => 'unique_phone_numbers_by_country', 'key' => { 'country_code' => '54' }, 'value' => 38 })
  end

  it "migrates remindem callers" do
    migrate_counter(
      { 'metric' => 'phone_numbers', 'key' => { 'country_code' => '54' }, 'value' => 38 },
      { 'metric' => 'unique_phone_numbers_by_country', 'key' => { 'country_code' => '54' }, 'value' => 38 })
  end
end
