class InstallationsListing < Listings::Base
  model Installation

  # scope :all, default: true

  layout filters: :top

  filter :application

  column :application, searchable: true
  column :admin_email, searchable: true
  column :uuid, searchable: true
  column :last_reported_at

  paginates_per 20
  
  export :csv, :xls

end