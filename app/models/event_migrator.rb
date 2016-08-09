# EventMigrator is resposible to change the event
# before it will be index in elasticsearch.
# Event submission is kept untouched in the db.
class EventMigrator

  def migrate_counter(counter)
    case counter['metric']
    when 'numbers_by_application_and_country' # mbuilder
      counter['metric'] =  'unique_phone_numbers_by_project_and_country'
      move counter['key'], 'application_id', 'project_id'
    when 'callers' # verboice
      counter['metric'] =  'unique_phone_numbers_by_project_and_country'
    when 'numbers_by_country_code' # pollit & nuntium
      counter['metric'] = 'unique_phone_numbers_by_country'
    when 'phone_numbers' # remindem
      counter['metric'] = 'unique_phone_numbers_by_country'
    end
  end

  private

  def move(hash, source, dest)
    hash[dest] = hash[source]
    hash.delete(source)
  end
end
