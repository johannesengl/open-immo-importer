require 'rails_helper'
require File.dirname(__FILE__) + '/../spec_helper'


RSpec.describe OpenImmo::PropertyItem do

  ENV['LOCAL_ESTATE_EXPORT_DIR'] = 'spec/fixtures/estate_export/'

  describe '#property_attribute_records' do

    let(:property_item) { OpenImmo::PropertyItem.new(nil) }
    let(:property_attribute_hash) {{
          :bad=>{:@wanne=>"true"},
          :kueche=>nil,
          :boden=>{:@parkett=>"true"},
          :heizungsart=>{:@zentral=>"true"},
          :befeuerung=>nil,
          :fahrstuhl=>{:@personen=>"true"},
          :stellplatzart=>{:@tiefgarage=>"true"},
          :ausricht_balkon_terrasse=>nil,
          :angeschl_gastronomie=>nil,
          :sicherheitstechnik=>nil,
          :gaestewc=>true
        }}

    it 'should create five categorys and six attributes and associate categories accordingly' do
      property_item.send(:property_attribute_records, property_attribute_hash)

      expect(PropertyAttributeCategory.count).to be(6)
      expect(PropertyAttribute.count).to be(6)
      expect(PropertyAttribute.find_by_key('wanne').property_attribute_category.key).to eq('bad')
    end

  end
end
