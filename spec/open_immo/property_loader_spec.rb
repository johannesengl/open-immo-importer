require 'rails_helper'
require File.dirname(__FILE__) + '/../spec_helper'

RSpec.describe OpenImmo::FtpImporter do

  ENV['LOCAL_ESTATE_EXPORT_DIR'] = 'spec/fixtures/estate_export/'

  it 'should be declared' do
    expect(OpenImmo::PropertyLoader).to be_a Class
  end

  describe '#sync_properties' do
    it 'should create one property', vcr: {cassette_name: "property_loader/sync_properties"} do
      seed_districts
      OpenImmo::PropertyLoader.sync_properties
      expect(Property.count).to be(1)
    end

    it 'should not duplicate property if same property gets synced or updated twice', vcr: {cassette_name: "property_loader/sync_properties"} do
      seed_districts

      2.times do
        OpenImmo::PropertyLoader.sync_properties
        expect(Property.count).to be(1)
      end
    end

    it 'should not duplicate associations if same property gets synced or updated twice', vcr: {cassette_name: "property_loader/sync_properties"} do
      seed_districts

      2.times do
        OpenImmo::PropertyLoader.sync_properties
        expect(Property.count).to be(1)
        expect(Address.count).to be(1)
        expect(EstateAgent.count).to be(1)
        expect(Property.first.property_images.count).to be(6)
        expect(Property.first.property_attributes.count).to be(8)
        expect(Property.first.property_attribute_categories.count).to be(7)
      end
    end
  end
end
