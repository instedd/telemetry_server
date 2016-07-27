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

  ALL_COUNTRY_CODES = ['54', '1', '855', '84']

  desc 'Removes all installation and events data'
  task prune_data: :environment do
    # Installation.where(application: 'resourcemap').destroy_all
    Installation.destroy_all
  end

  desc 'Creates and indexes fake data for the last 10 months'
  task fake_data: :environment do

    last_period    = Time.now.utc.beginning_of_week
    current_period = (last_period - 10.months).beginning_of_week

    init_state

    while(current_period < last_period)
      record_stats(current_period)
      current_period += 1.week
      advance_state
    end

  end

  def init_state
    @instance_classes = [FakeVerboiceInstance, FakeNuntiumInstance, FakeResourcemapInstance]
    initial_instances = 5

    @instances = []
    initial_instances.times {
      @instance_classes.each { |instance_class|
        @instances << instance_class.new
      }
    }
  end

  def advance_state
    @instances.each(&:advance_state)
    rand(2).times {@instance_classes.each { |instance_class| @instances << instance_class.new } } if rand(3) == 0
  end

  def record_stats(current_period)
    @instances.each do |instance|
      installation = Installation.find_or_create_by(uuid: instance.uuid) do |i|
        i.latitude = instance.latitude
        i.longitude = instance.longitude
        i.application = instance.application
      end
      installation.events.build(data: instance.current_stats(current_period).to_json).save
    end
  end

  class FakeInstance
    attr_reader :uuid
    attr_reader :latitude
    attr_reader :longitude
    attr_reader :application

    def initialize
      @latitude, @longitude  = LOCATIONS.sample
      @uuid = SecureRandom.uuid
    end

    protected

    def build_event(all_stats, period)
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
  end

  module FakeUserContainer
    extend ActiveSupport::Concern

    included do
      attr_reader :users

      def users_container_init
        @user_id_seq = 0
        @users = []
      end

      def users_container_advance_state
        @users.each(&:advance_state)
      end

      def create_user
        @users << build_user
      end

      def new_user_id
        @user_id_seq+=1
      end

      def build_user
        raise "should implement"
      end

      def user_lifespan_stats
        {
          "timespans" => @users.map { |user|
            {
              "metric" => "account_lifespan",
              "key" => { "user_id" => user.id },
              "days" => user.lifespan
            }
          }
        }
      end

      def number_of_accounts_stats
        {
          "counters" => [
            { "metric" => "accounts", "key" => { }, "value" => @users.length }
          ]
        }
      end
    end

    class BaseUser
      attr_reader :id
      attr_reader :lifespan

      def initialize(instance)
        @id = instance.new_user_id
        @instance = instance
        @lifespan = rand(10)
      end

      def advance_state
        @lifespan += rand(14)
      end
    end
  end

  class FakeNuntiumInstance < FakeInstance
    def initialize
      super
      @application = 'nuntium'
      @ao_count = 0
      @at_count = 0
      @channels_by_kind = Hash.new 0
    end

    def current_stats(period)
      all_stats = [
        unique_phone_numbers_per_country_code,
        ao_count,
        at_count,
        active_channels_by_type,
        channels_by_kind
      ]

      build_event(all_stats, period)
    end

    def advance_state
    end

    def unique_phone_numbers_per_country_code
      {
        "counters" => ALL_COUNTRY_CODES.map { |country_code|
          {
            "metric" => "numbers_by_country_code",
            "key" => { "country_code" => country_code },
            "value" => rand(50)
          }
        }
      }
    end

    def ao_count
      {
        "counters" => [
          {
            "metric" => "ao_messages",
            "key" => {},
            "value" => (@ao_count += rand(1000))
          }
        ]
      }
    end

    def at_count
      {
        "counters" => [
          {
            "metric" => "at_messages",
            "key" => {},
            "value" => (@at_count += rand(1000))
          }
        ]
      }
    end

    def active_channels_by_type
      {
        "counters" => %w(twilio voxeo custom custom_sip).map { |type|
          {
            "metric" => "active_channels_by_type",
            "key" => { "type" => type },
            "value" => rand(30)
          }
        }
      }
    end

    def channels_by_kind
      {
        "counters" => ['clickatell', 'msn', 'dtac', 'xmpp', 'twilio'].map { |kind|
          {
            "metric" => "channels_by_kind",
            "key" => { "kind" => kind },
            "value" => (@channels_by_kind[kind] += rand(20))
          }
        }
      }
    end
  end

  class FakeVerboiceInstance < FakeInstance
    include FakeUserContainer

    def initialize
      super
      @application = 'verboice'
      @project_id_seq = 0
      @call_flow_id_seq = 0
      users_container_init
      10.times { create_user }
    end

    def build_user
      FakeUser.new(self)
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
        number_of_accounts_stats,
        call_flows_per_project_stats,
        languages_per_project_stats,
        project_count_stats,
        project_lifespan_stats,
        steps_per_call_flow_stats,
        calls_per_day_stats
      ]

      build_event(all_stats, period)
    end

    def all_projects
      @users.flat_map(&:projects)
    end

    def call_flows_per_project_stats
      {
        "counters" => all_projects.map { |project|
          {
            "metric" => "call_flows",
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
            "metric" => "languages",
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
            "metric" => "projects",
            "key" => {},
            "value" => all_projects.length
          }
        ]
      }
    end

    def project_lifespan_stats
      {
        "timespans" => all_projects.map { |project|
          {
            "metric" => "project_lifespan",
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
              "metric" => "steps",
              "key" => { "call_flow" => call_flow[:id] },
              "value" => call_flow[:step_count]
            }
          }
        }
      }
    end

    def calls_per_day_stats
      {
        "counters" => all_projects.flat_map { |project|
          grouped_calls = project.call_logs.group_by{ |call_flow| [call_flow[:channel_id], call_flow[:date], call_flow[:state]] }

          grouped_calls.map do |key, flows|
            {
              "metric" => "calls",
              "key" => { "channel_id" => key[0], "date" => key[1], "state" => key[2] },
              "value" => flows.length
            }
          end
        }
      }
    end

    def advance_state
      users_container_advance_state
      rand(4).times { create_user }
    end

    class FakeUser < FakeUserContainer::BaseUser
      attr_reader :projects

      def initialize(instance)
        super
        @projects = []
        rand(2).times { create_project }
      end

      def create_project
        @projects << FakeProject.new(@instance, self)
      end

      def advance_state
        super
        @projects.each(&:advance_state)
        rand(1).times { create_project }
      end
    end

    class FakeProject

      attr_reader :id
      attr_reader :languages
      attr_reader :call_flows
      attr_reader :channels
      attr_reader :lifespan

      def initialize(instance, user)
        @instance = instance
        @user = user

        @id = instance.new_project_id
        @languages = ALL_LANGUAGES.sample(1 + rand(2))
        @call_flows = []
        rand(5).times { create_flow }
        @channels = rand(@call_flows.length * 1.5)
        @lifespan = rand(5)
      end

      def create_flow
        @call_flows << {
          id: (@instance.new_call_flow_id),
          step_count: 1 + rand(20)
        }
      end

      def call_logs
        (0..channels).flat_map do |channel|
          (0..rand(3)).map do
            {
              channel_id: channel,
              date: (Date.today - rand(7)).iso8601,
              state: ["completed", "failed"].sample
            }
          end
        end
      end

      def advance_state
        @lifespan += rand(14)

        call_flows.each do |flow|
          languages.concat(ALL_LANGUAGES.sample(1)).uniq! if rand(30) == 0
          flow[:step_count] += rand(2)
        end

        @channels += rand(3)
      end

    end
  end

  class FakeResourcemapInstance < FakeInstance
    include FakeUserContainer

    def initialize
      super
      @application = 'resourcemap'
      users_container_init
      @collections = []
      @collection_id_seq = 0
    end

    def build_user
      FakeUser.new(self)
    end

    def new_collection_id
      @collection_id_seq += 1
    end

    def current_stats(period)
      all_stats = [
        user_lifespan_stats,
        number_of_accounts_stats,
        activities_by_collection,
      ]

      build_event(all_stats, period)
    end

    def advance_state
      rand(4).times { create_user }
      users_container_advance_state
      rand(2).times { create_collection }
    end

    def create_collection
      @collections << FakeCollection.new(self)
    end

    def activities_by_collection
      {
        "counters" => @collections.map { |c|
        { "metric" => "activities", "key" => { "collection_id" => c.id }, "value" => c.activities}
        }
      }
    end

    class FakeUser < FakeUserContainer::BaseUser
      def initialize(instance)
        super
      end

      def advance_state
        super
      end
    end

    class FakeCollection
      attr_reader :id

      def initialize(instance)
        @instance = instance
        @id = instance.new_collection_id
        @activities = PositiveIntegerRandomGaussian.new(rand(20), rand(5))
      end

      def advance_state
      end

      def activities
        @activities.rand
      end
    end
  end

  # based on http://stackoverflow.com/a/9266488/30948
  # a normal distribution helper to generate positive integers numbers
  # useful to define generators that will lead to simulations of heavy used instances and low used instance
  # instead of uniform random activities metrics
  class PositiveIntegerRandomGaussian
    def initialize(mean = 0.0, sd = 1.0, rng = lambda { Kernel.rand })
      @mean, @sd, @rng = mean, sd, rng
      @compute_next_pair = false
    end

    def rand
      res = if (@compute_next_pair = !@compute_next_pair)
        # Compute a pair of random values with normal distribution.
        # See http://en.wikipedia.org/wiki/Box-Muller_transform
        theta = 2 * Math::PI * @rng.call
        scale = @sd * Math.sqrt(-2 * Math.log(1 - @rng.call))
        @g1 = @mean + scale * Math.sin(theta)
        @g0 = @mean + scale * Math.cos(theta)
      else
        @g1
      end

      [res, 0].max
    end
  end
end
