class EventsListing < Listings::Base
  model { Event.where(installation_id: params[:installation_id]).order('created_at DESC') }

  layout filters: :top

  column :id
  column :created_at
  column :period_beginning
  column :period_end

  column :has_reported_errors?, sortable: false, title: 'Errors' do |event|
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

  paginates_per 15
end
