module Jsonapi
  module Matchers
    class RecordCount
      include Jsonapi::Matchers::Shared

      def initialize(expected, location)
        @expected = expected
        @location = location
        @failure_message = nil
      end

      def matches?(target)
        @target = normalize_target(target)
        return false unless @target

        case @location
        when 'data'
          @target = @target[@location]
        when 'included'
          @target = @target[@location]
        end

        case @target
        when Array
          @target.count == @expected
        when ::Hash
          @expected == 1
        else
          @failure_message = "Expected value of #{@location} to be an Array or Hash but was #{target.inspect}"
          return false
        end
      end

      def failure_message
        @failure_message || "expected object count '#{@expected}', but was #{@target.is_a?(Array) ? @target.count : 1}"
      end
    end

    module Record
      def have_jsonapi_record_count(expected)
        RecordCount.new(expected, 'data')
      end

      def include_jsonapi_record_count(expected)
        RecordCount.new(expected, 'included')
      end
    end
  end
end
