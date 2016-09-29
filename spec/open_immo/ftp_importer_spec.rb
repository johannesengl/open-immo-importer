require 'rails_helper'
require File.dirname(__FILE__) + '/../spec_helper'


RSpec.describe OpenImmo::FtpImporter do

  ENV['LOCAL_ESTATE_EXPORT_DIR'] = 'spec/fixtures/estate_export/'
  let(:ftp_importer) { OpenImmo::FtpImporter.new }

  it 'should be declared' do
    expect(OpenImmo::FtpImporter).to be_a Class
  end

  describe '#read_xml_files' do
    it 'should read content of all xml files in estate export directory' do
      expect(ftp_importer.read_xml_files.count).to be(1)
    end
  end
end
