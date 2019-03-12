module Jsonapi
  module Matchers
    class ErrorIncluded
      include Jsonapi::Matchers::Shared

      def with_code(error_code)
        @error_code = error_code
        self
      end

      def matches?(target)
        @target = normalize_target(target)
        return false unless @target

        @value = @target.try(:[], :errors)

        if @error_code
          includes_error?
        else
          has_error?
        end
      end

      def failure_message
        @failure_message
      end

      private

      def has_error?
        @failure_message = "expected any error code, but got '#{@value}'"

        !@value.nil? && @value.any?
      end

      def includes_error?
        @failure_message = "expected error code '#{@error_code}', but got '#{@value}'"

        !@value.nil? && @value.any? { |v| v['code'] == @error_code }
      end
    end

    module Error
      def have_jsonapi_error
        ErrorIncluded.new
      end
    end
  end
end
