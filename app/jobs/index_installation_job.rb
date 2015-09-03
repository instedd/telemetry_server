class IndexInstallationJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id)
    installation = Installation.find_by(id: installation_id)
    return if installation.nil?

    InstallationIndexer.new.index(installation)
  end
end
