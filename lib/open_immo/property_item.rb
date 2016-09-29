module OpenImmo
  class PropertyItem

    attr_accessor :record

    def initialize(property_data)
      @property_data = property_data
      online_id = property_data.try(:[], :verwaltung_techn).try(:[], :objektnr_extern)
      @record = Property.find_by_online_id(online_id) if online_id
      @record = Property.new if @record.nil?
    end

    def sync_action
      @property_data[:verwaltung_techn].try(:[], :aktion).try(:[], :@aktionart)
    end

    def update_or_create_record
      set_fields
      @record.save unless @record.persisted?
      set_images
      @record.save
    end

    def destroy_record
      @record.destroy if @record.persisted?
    end

    def online_id
      @property_data[:verwaltung_techn].try(:[], :objektnr_extern)
    end

    protected

    def set_fields
      @record.online_id = online_id
      @record.category = category
      @record.estate_agent = EstateAgent.find_or_create_by(contact_person) if contact_person
      @record.price = price
      @record.house_expenses = house_expenses
      @record.rooms = rooms
      @record.size_living = size_living
      @record.size_usage = size_usage
      @record.size_land = size_land
      @record.number_parking_spaces = number_parking_spaces
      @record.facility_category = facility_category
      @record.property_attributes = property_attribute_records(@property_data[:ausstattung])
      @record.state_key = state_key
      @record.age = age
      @record.age_type_key = age_type_key
      @record.cover_image = cover_image_file if cover_image_file
      @record.blue_print = blue_print_file if blue_print_file
      @record.address = Address.find_or_create_by(address) if address
      @record.district = District.find_by(name: district_name)
      @record.link_360_degrees = link_360_degrees
      @record.energy_performance_certificate_type = energy_performance_certificate_type
      @record.energy_performance_value = energy_performance_value
      @record.energy_performance_certificate_expires_at = energy_performance_certificate_expires_at
    end

    def set_images
      @record.property_images.destroy_all
      @record.property_images << image_records
    end

    def category
      category_keys = @property_data[:objektkategorie].try(:[], :objektart).try(:keys)
      if category_keys.try(:include?, :wohnung)
        :appartment
      elsif category_keys.try(:include?, :haus)
        :house
      elsif category_keys.try(:include?, :grundstueck)
        :land
      else
        :unknown
      end
    end

    def address
      address_data = @property_data[:geo]
      return nil unless address_data
      {
        street: address_data[:strasse],
        street_no: address_data[:hausnummer],
        city: address_data[:ort],
        zip: address_data[:plz],
        number_floors: address_data[:anzahl_etagen],
        floor: address_data[:etage]
      }
    end

    def district_name
      @property_data[:geo].try(:[], :regionaler_zusatz)
    end

    def contact_person
      contact_data = @property_data[:kontaktperson]
      return nil unless contact_data
      {
        firstname: contact_data[:vorname],
        lastname: contact_data[:name],
        email: contact_data[:email_direkt],
        phone: contact_data[:tel_durchw]
      }
    end

    def price
      price_data = @property_data[:preise]
      price = price_data.try(:[], :kaufpreis).to_f
      price = price * 1.19 if price_data.try(:[], :zzg_mehrwertsteuer)
      price
    end

    def house_expenses
      @property_data[:preise].try(:[], :hausgeld).try(:to_i)
    end

    def rooms
      @property_data[:flaechen].try(:[], :anzahl_zimmer).try(:to_i)
    end

    def size_living
      @property_data[:flaechen].try(:[], :wohnflaeche).try(:to_i)
    end

    def size_usage
      @property_data[:flaechen].try(:[], :nutzflaeche).try(:to_i)
    end

    def size_land
      @property_data[:flaechen].try(:[], :grundstuecksflaeche).try(:to_i)
    end

    def number_parking_spaces
      @property_data[:flaechen].try(:[], :anzahl_stellplaetze).try(:to_i)
    end

    def facility_category
      @property_data[:ausstattung].try(:[], :ausstatt_kategorie)
    end

    def facilities
      @property_data[:ausstattung].keys
    end

    def state_key
      @property_data[:zustand_angaben].try(:[], :zustand).try(:[], :@zustand_art)
    end

    def energy_performance_certificate_type
      @property_data[:zustand_angaben].try(:[], :energiepass).try(:[], :epart)
    end

    def energy_performance_value
      @property_data[:zustand_angaben].try(:[], :energiepass).try(:[], :endenergiebedarf).try(:to_f)
    end

    def energy_performance_certificate_expires_at
      @property_data[:zustand_angaben].try(:[], :energiepass).try(:[], :gueltig_bis).try(:to_date)
    end

    def age
      @property_data[:zustand_angaben].try(:[], :baujahr).try(:to_i)
    end

    def age_type_key
      @property_data[:zustand_angaben].try(:[], :alter).try(:[], :@alter_attr)
    end

    def attachments
      attachments = @property_data.try(:[], :anhaenge).try(:[], :anhang)
      case attachments
      when Hash
        [attachments]
      when Array
        attachments
      else
        []
      end
    end

    def cover_image_file
      cover_filenames = attachments.select{|e| e[:@gruppe] == "TITELBILD"}
      cover_file = get_file(cover_filenames[0].try(:[], :daten).try(:[], :pfad))
      cover_file = image_files.first unless cover_file
      cover_file
    end

    def blue_print_file
      blue_print_filenames = attachments.select{|e| e[:@gruppe] == "DOKUMENTE"}
      get_file(blue_print_filenames[0].try(:[], :daten).try(:[], :pfad))
    end

    def image_files
      image_files = attachments.map do |attachment|
        get_file(attachment.try(:[], :daten).try(:[], :pfad)) if is_image_file?(attachment)
      end
      image_files.compact
    end

    def is_image_file?(attachment)
      image_formats = ['JPG', 'jpg', 'JPEG', 'jpeg', 'PNG', 'png']
      image_formats.include?(attachment.try(:[], :format))
    end

    def get_file(file_name)
      return nil unless file_name
      path = Dir.glob("#{ENV['LOCAL_ESTATE_EXPORT_DIR']}*/**#{file_name}").try(:first) ||
        Dir.glob("#{ENV['LOCAL_ESTATE_EXPORT_DIR']}**#{file_name}").try(:first)
      File.new(path) if path
    end

    def image_records
      image_files.map do |image_file|
        property_image = PropertyImage.find_by_image(File.basename image_file)
        property_image = PropertyImage.create(image: image_file) unless property_image
        property_image
      end
    end

    def link_360_degrees
      links_360 = attachments.select{ |e| e[:@gruppe] == "LINKS" && e[:anhangtitel].include?("360-grad")}
      links_360[0].try(:[], :anhangtitel)
    end

    def property_attribute_records(attributes_hash)
      attributes = []
      pac_general = find_or_create_property_attribute_category("general")
      attributes_hash.each do |key, value|
        case value
        when Hash
          attributes << crate_attributes_from_category_hash(key, value)
        when true
          attributes << PropertyAttribute.find_or_create_by(key: key) do |property_attribute|
            property_attribute.name = key.capitalize
            property_attribute.property_attribute_category = pac_general
          end
        end
      end
      attributes.flatten
    end

    def crate_attributes_from_category_hash(key, value)
      attributes = []
      pac = find_or_create_property_attribute_category(key)
      value.each do |key2, value2|
        key2 = key2.to_s.remove('@')
        attributes << PropertyAttribute.find_or_create_by(key: key2) do |property_attribute|
          property_attribute.name = key2.capitalize
          property_attribute.property_attribute_category = pac
        end
      end
      attributes
    end

    def find_or_create_property_attribute_category(key)
      PropertyAttributeCategory.find_or_create_by(key: key) do |pac|
        pac.name = key.to_s.capitalize
      end
    end

  end
end
