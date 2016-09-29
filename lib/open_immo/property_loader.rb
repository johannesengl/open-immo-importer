module OpenImmo
  class PropertyLoader

    def self.sync_properties
      ftp_importer.clean_up_local_tmp_dir if ftp_importer
      property_data_array = get_properties_data
      property_data_array.each do |property_data|
        property = PropertyItem.new(property_data)
        case property.sync_action
        when "CHANGE"
          property.update_or_create_record
          log_sync_property(property, property_data)
        when "DELETE"
          property.destroy_record
          PROPERTY_LOADER_LOGGER.info "Deleted Property #{property.online_id}"
        end
      end
    end

    protected

    def self.ftp_importer
      @@ftp_importer ||= FtpImporter.create_importer
    end

    def self.log_sync_property(property, property_data)
      if property.record.persisted?
        PROPERTY_LOADER_LOGGER.info "Sucessfully snyced Property #{property.online_id}"
      else
        PROPERTY_LOADER_LOGGER.info("Error creating Property #{property.online_id}")
        PROPERTY_LOADER_LOGGER.info(property.record.errors.full_messages.join(', '))
        PROPERTY_LOADER_DATA_LOGGER.info(property_data)
      end
    end

    def self.get_properties_data
      xml_files = ftp_importer.present? ? ftp_importer.read_xml_files : []
      property_data_array = combine_to_property_data_array(xml_files)
      FTP_IMPORTER_LOGGER.info "#{property_data_array.count} properties found to sync!"
      property_data_array
    end

    def self.combine_to_property_data_array(xml_files)
      xml_files.map do |data|
        property_data = parse_xml_string(data).try(:[],:openimmo).try(:[], :anbieter).try(:[], :immobilie) || []
        property_data = [property_data] if property_data.is_a?(Hash)
        property_data
      end.flatten
    end

    def self.parse_xml_string(string)
      parser = Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
      parser.parse(string)
    end

  end
end
