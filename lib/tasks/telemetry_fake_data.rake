namespace :telemetry do
  
  ALL_LANGUAGES = [:AF, :EN, :ES, :FR, :KO, :PT]
  
  LOCATIONS = [
    [-34.569614, -58.448061],
    [37.775545, -122.442750],
    [6.320564, -10.752099],
    [-14.424955, 27.165738],
    [49.350156, 9.266661],
    [40.543003, 113.329152],
    [14.556971, -87.588810],
    [-11.743711, -49.268501]
  ]

  desc 'Creates and indexes fake data'
  task fake_data: :environment do

    current_period = "2015-01-01T00:00:00:00".to_datetime
    last_period    = "2015-09-07T00:00:00:00".to_datetime

    init_state

    while(current_period < last_period)
      record_stats(current_period)
      current_period += 1.week
      advance_state
    end

  end

  def init_state
    @instances = (1..8).map { FakeInstance.new }
  end

  def advance_state
    @instances.each(&:advance_state)
    rand(2).times { @instances << FakeInstance.new } if rand(3) == 0
  end

  def record_stats(current_period)
    @instances.each do |instance|
      installation = Installation.find_or_create_by(uuid: instance.uuid) { |i| i.latitude = instance.latitude; i.longitude = instance.longitude }
      installation.events.build(data: instance.current_stats(current_period).to_json).save
    end
  end

  class FakeInstance

    attr_reader :uuid
    attr_reader :latitude
    attr_reader :longitude

    def initialize
      @user_id_seq = 0
      @project_id_seq = 0
      @call_flow_id_seq = 0
      @latitude, @longitude  = LOCATIONS.sample

      @uuid = SecureRandom.uuid
      @users = (1..10).map { create_user }
    end

    def create_user
      FakeUser.new(self)
    end

    def new_user_id
      @user_id_seq+=1
    end

    def new_project_id
      @project_id_seq+=1
    end

    def new_call_flow_id
      @call_flow_id_seq+=1
    end

    def current_stats(period)
      all_stats = [
        user_lifespan_stats,
        call_flows_per_project_stats,
        languages_per_project_stats,
        project_count_stats,
        project_lifespan_stats,
        steps_per_call_flow_stats
      ]

      base = {
        "period" => { "beginning" => period.iso8601, "end" => (period + 1.week).iso8601 },
        "counters" => [],
        "sets" => [],
        "timespans" => []
      }

      all_stats.inject(base) do |result, stats|
        result.tap do |r|
          r["counters"].concat(stats["counters"])           if stats["counters"]
          r["sets"].concat(stats["sets"])                   if stats["sets"]
          r["timespans"].concat(stats["timespans"])         if stats["timespans"]
        end
      end
    end

    def all_projects
      @users.flat_map(&:projects)
    end

    def call_flows_per_project_stats
      {
        "counters" => all_projects.map { |project|
          {
            "kind" => "call_flows",
            "key" => { "project_id" => project.id },
            "value" => project.call_flows.length
          }
        }
      }
    end

    def languages_per_project_stats
      {
        "sets" => all_projects.map { |project|
          {
            "kind" => "languages",
            "key" => { "project_id" => project.id },
            "elements" => project.languages
          }
        }
      }
    end

    def project_count_stats
      {
        "counters" => [
          {
            "kind" => "projects",
            "key" => {},
            "value" => all_projects.length
          }
        ]
      }
    end

    def user_lifespan_stats
      {
        "timespans" => @users.map { |user|
          {
            "kind" => "user_lifespan",
            "key" => { "user_id" => user.id },
            "days" => user.lifespan
          }
        }
      }
    end

    def project_lifespan_stats
      {
        "timespans" => all_projects.map { |project|
          {
            "kind" => "project_lifespan",
            "key" => { "project_id" => project.id },
            "days" => project.lifespan
          }
        }
      }
    end

    def steps_per_call_flow_stats
      {
        "counters" => all_projects.flat_map { |project|
          project.call_flows.map { |call_flow|
            {
              "kind" => "steps",
              "key" => { "call_flow" => call_flow[:id] },
              "value" => call_flow[:step_count]
            }
          }
        }
      }
    end

    def advance_state
      @users.each(&:advance_state)
      rand(4).times { @users << create_user }
    end

  end

  class FakeUser
    attr_reader :id
    attr_reader :projects
    attr_reader :lifespan

    def initialize(instance)
      @id = instance.new_user_id
      @instance = instance
      @projects = (0..rand(2)).map { create_project }
      @lifespan = rand(10)
    end

    def create_project
      FakeProject.new(@instance, self)
    end

    def advance_state
      @lifespan += rand(14)
      @projects.each(&:advance_state)
      rand(1).times { @projects << create_project }
    end

  end

  class FakeProject

    attr_reader :id
    attr_reader :languages
    attr_reader :call_flows
    attr_reader :lifespan

    def initialize(instance, user)
      @instance = instance
      @user = user
      
      @id = instance.new_project_id
      @languages = ALL_LANGUAGES.sample(1 + rand(2))
      @call_flows = (0..rand(5)).map { create_flow }
      @lifespan = rand(5)
    end

    def create_flow
      {
        id: (@instance.new_call_flow_id),
        step_count: 1 + rand(20)
      }
    end

    def advance_state
      @lifespan += rand(14)

      call_flows.each do |flow|
        languages.concat(ALL_LANGUAGES.sample(1)).uniq! if rand(30) == 0
        flow[:step_count] += rand(2)
      end
    end

  end

end
