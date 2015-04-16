require 'heroku/client/pgbackups'
class Fourchette::Pgbackups
  include Fourchette::Logger

  def initialize
    @heroku = Fourchette::Heroku.new
  end

  def copy(from, to)
    from_url, from_name = pg_details_for(from)
    to_url, to_name = pg_details_for(to)

    @client =  Heroku::Client::Pgbackups.new pgbackup_url(from) + '/api'
    @client.create_transfer(from_url, from_name, to_url, to_name)
  end

  private

  def existing_backups?(heroku_app_name)
    @heroku.client.addon.list(heroku_app_name).select do |addon|
      addon['name'] == 'pgbackups'
    end.any?
  end

  def pg_details_for(app_name)
    [@heroku.config_vars(app_name)['DATABASE_URL'], 'DATABASE_URL']
  end

  def pgbackup_url(app_name)
    @heroku.config_vars(app_name).each do |k, v|
      return v if k == 'PGBACKUPS_URL'
    end
  end
end
