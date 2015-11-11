class EventsListing < Listings::Base
  model { Event.where(installation_id: params[:installation_id]) }

  layout filters: :top

  # filter :application

  # column :application, searchable: true
  # column :admin_email, searchable: true

  # column :uuid, title: 'UUID', searchable: true

  column :id

  column :created_at

  column :has_reported_errors?, title: 'Errors' do |event|
    if event.has_reported_errors?
      content_tag(:i, nil, class: 'glyphicon glyphicon-remove', style: 'color: red;')
    else
      content_tag(:i, nil, class: 'glyphicon glyphicon-ok', style: 'color: green;')
    end
  end

  column nil, title: 'Actions' do |event|
    if event.has_reported_errors?
      link_to 'View errors', errors_installation_event_path(event.installation, event)
    end
  end

  # column :last_reported_at, title: 'Last report' do |installation|
  #   if installation.opt_out
  #     content_tag(:i, nil, class: 'glyphicon glyphicon-remove', title: 'Opted out of reporting')
  #   elsif installation.last_reported_at.present?
  #     installation.last_reported_at
  #   else
  #     content_tag(:i, nil, class: 'glyphicon glyphicon-minus', title: 'No stats reported yet')
  #   end
  # end
  #
  # column :last_errored_at, title: 'Last error' do |installation|
  #   if installation.last_errored_at.present?
  #     installation.last_errored_at
  #   else
  #     content_tag(:i, nil, class: 'glyphicon glyphicon-minus', title: 'No errors reported yet')
  #   end
  # end

  paginates_per 10

  # export :csv, :xls

end
