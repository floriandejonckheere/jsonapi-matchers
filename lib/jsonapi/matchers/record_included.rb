module Jsonapi
  module Matchers
    class RecordIncluded
      include Jsonapi::Matchers::Shared

      def initialize(expected, location)
        @expected = expected
        @location = location
        @failure_message = nil
        @failure_message_when_negated = nil
      end

      def matches?(target)
        @target = normalize_target(target)
        return false unless @target

        case @location
        when 'data'
          target_location = @target[@location]
        when 'included'
          target_location = @target[@location]
        end

        case target_location
        when Array
          if @expected.respond_to? :each
            # target_location is Array, @expected is Array
            @expected.all? { |e| target_location.any? { |t| has_record? t, e } }
          else
            # target_location is Array, @expected is object
            target_location.any? { |t| has_record? t, @expected }
          end
        when ::Hash
          if @expected.respond_to? :each
            # target_location is object, @expected is Array
            @expected.all? { |e| has_record? target_location, e }
          else
            # target_location is object, @expected is object
            has_record? target_location, @expected
          end
        else
          @failure_message = "Expected value of #{@location} to be an Array or Hash but was #{target.inspect}"
          return false
        end
      end

      def failure_message
        return @failure_message if @failure_message

        if @expected.respond_to? :each
          "expected objects with ids of #{@expected.map { |e| "'#{e.id}'" }.join ', '} to be included in #{@target.as_json.ai}"
        else
          "expected object with an id of '#{@expected.id}' to be included in #{@target.as_json.ai}"
        end
      end

      def failure_message_when_negated
        return @failure_message_when_negated if @failure_message_when_negated

        if @expected.respond_to? :each
          "expected objects with ids of #{@expected.map { |e| "'#{e.id}'" }.join ', '} to not be included in #{@target.as_json.ai}"
        else
          "expected object with an id of '#{@expected.id}' to not be included in #{@target.as_json.ai}"
        end
      end

      private

      def has_record?(target, expected)
        target.with_indifferent_access["id"] == expected.id.to_s
      end
    end

    module Record
      def have_jsonapi_record(expected)
        RecordIncluded.new(expected, 'data')
      end

      def have_jsonapi_records(expected)
        RecordIncluded.new(expected, 'data')
      end

      def include_jsonapi_record(expected)
        RecordIncluded.new(expected, 'included')
      end
    end
  end
end
