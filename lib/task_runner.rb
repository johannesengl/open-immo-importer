class TaskRunner

  def sync_properties
    OpenImmo::PropertyLoader.sync_properties
  end
  handle_asynchronously :sync_properties

end
