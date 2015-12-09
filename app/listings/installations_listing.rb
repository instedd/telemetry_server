class InstallationsListing < Listings::Base
  model Installation

  layout filters: :top

  filter :application

  column :application, searchable: true
  column :admin_email, searchable: true
  column :ip, title: 'IP'
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

  column :last_errored_at, title: 'Last error' do |installation|
    if installation.last_errored_at.present?
      installation.last_errored_at
    else
      content_tag(:i, nil, class: 'glyphicon glyphicon-minus', title: 'No errors reported yet')
    end
  end

  column nil, title: 'Actions' do |installation|
    link_to 'Events', installation_events_path(installation)
  end

  paginates_per 20

  export :csv, :xls

end
