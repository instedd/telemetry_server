class InstallationsListing < Listings::Base
  model Installation

  layout filters: :top

  filter :application

  column :application, searchable: true
  column :admin_email, searchable: true
  
  column :uuid, title: 'UUID', searchable: true
    
  column :last_reported_at, title: 'Last report' do |installation|
    if installation.opt_out
      content_tag(:i, nil, class: 'glyphicon glyphicon-remove', title: 'Opted out of reporting')
    elsif installation.last_reported_at.present?
      installation.last_reported_at
    else
      content_tag(:i, nil, class: 'glyphicon glyphicon-minus', title: 'No stats reported yet')
    end
  end

  paginates_per 20
  
  export :csv, :xls

end